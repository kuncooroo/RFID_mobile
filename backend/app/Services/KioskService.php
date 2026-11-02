<?php

namespace App\Services;

use App\Contracts\Repositories\RfidRepositoryInterface;
use App\Enums\UserRole;
use App\Exceptions\DomainException;
use App\Models\Cart;
use App\Models\KioskLocation;
use App\Models\Member;
use App\Models\RfidMember;
use App\Models\RfidVerification;
use App\Models\User;
use App\Models\UserFaceEnrollment;
use App\Models\UserSetting;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Kiosk self-service flows — does not alter mobile verify ownership rules.
 */
class KioskService
{
    public function __construct(private readonly RfidRepositoryInterface $rfid)
    {
    }

    /**
     * @return array{ok:true,api:string}
     */
    public function health(): array
    {
        return [
            'ok' => true,
            'api' => 'kiosk',
            'time' => now()->toIso8601String(),
        ];
    }

    /**
     * Lookup an RFID UID without requiring a bound visitor.
     *
     * @return array<string, mixed>
     */
    public function lookupRfid(string $code): array
    {
        try {
            $code = $this->normalizeCode($code);
        } catch (DomainException) {
            return $this->lookupPayload(
                status: 'invalid',
                rfidUid: trim($code),
                memberCode: null,
                isActive: null,
                cardStatus: 'invalid',
                user: null,
            );
        }

        if (! $this->isValidUidFormat($code)) {
            return $this->lookupPayload(
                status: 'invalid',
                rfidUid: $code,
                memberCode: null,
                isActive: null,
                cardStatus: 'invalid',
                user: null,
            );
        }

        $member = $this->rfid->findMemberByCode($code);

        if (! $member) {
            return $this->lookupPayload(
                status: 'unregistered',
                rfidUid: $code,
                memberCode: null,
                isActive: null,
                cardStatus: 'unknown',
                user: null,
            );
        }

        if (! $member->is_active) {
            $member->loadMissing('user.member');

            return $this->lookupPayload(
                status: 'inactive',
                rfidUid: $member->rfid_uid,
                memberCode: $member->member_code,
                isActive: false,
                cardStatus: 'inactive',
                user: $this->userPayload($member),
                rfidMemberId: (int) $member->id,
                card: $member,
            );
        }

        if ($member->user_id === null) {
            return $this->lookupPayload(
                status: 'issued',
                rfidUid: $member->rfid_uid,
                memberCode: $member->member_code,
                isActive: true,
                cardStatus: 'ready',
                user: null,
                rfidMemberId: (int) $member->id,
                card: $member,
            );
        }

        $member->loadMissing('user.member');

        return $this->lookupPayload(
            status: 'registered',
            rfidUid: $member->rfid_uid,
            memberCode: $member->member_code,
            isActive: true,
            cardStatus: 'active',
            user: $this->userPayload($member),
            rfidMemberId: (int) $member->id,
            card: $member,
        );
    }

    /**
     * Resolve an active RFID / QR code to a bound visitor.
     *
     * @return array{user_id:?int,name:string,rfid_uid:string,member_code:string,rfid_member_id:int}
     */
    public function verifyCode(string $code): array
    {
        $lookup = $this->lookupRfid($code);

        return match ($lookup['status']) {
            'inactive' => throw new DomainException('Kartu RFID nonaktif.', 422, 'kiosk_member_inactive'),
            'issued', 'registered' => [
                'user_id' => isset($lookup['user']['user_id']) ? (int) $lookup['user']['user_id'] : null,
                'name' => (string) ($lookup['user']['name'] ?? $lookup['member_code'] ?? 'Kartu'),
                'rfid_uid' => (string) $lookup['rfid_uid'],
                'member_code' => (string) ($lookup['member_code'] ?? ''),
                'rfid_member_id' => (int) ($lookup['rfid_member_id'] ?? 0),
            ],
            default => throw new DomainException(
                'Kartu ini belum diterbitkan.',
                422,
                'kiosk_card_not_issued',
            ),
        };
    }

    /**
     * Create a visitor and bind the scanned RFID card (self-service).
     *
     * @param  array{name:string,email?:string|null,phone?:string|null}  $data
     * @return array<string, mixed>
     */
    public function registerVisitor(string $rfidUid, array $data): array
    {
        $lookup = $this->lookupRfid($rfidUid);

        if ($lookup['status'] === 'inactive') {
            throw new DomainException('Kartu RFID nonaktif dan tidak dapat didaftarkan.', 422, 'kiosk_member_inactive');
        }

        if ($lookup['status'] === 'registered') {
            throw new DomainException('Kartu RFID sudah terdaftar pada akun lain.', 409, 'kiosk_rfid_already_registered');
        }

        if ($lookup['status'] !== 'issued' || empty($lookup['rfid_member_id'])) {
            throw new DomainException(
                'Kartu ini belum diterbitkan. WanderDesa memakai kartu yang sudah jadi.',
                422,
                'kiosk_card_not_issued',
            );
        }

        $name = trim((string) ($data['name'] ?? ''));
        $email = $this->nullableString($data['email'] ?? null);
        $phone = $this->nullableString($data['phone'] ?? null);
        $profile = $this->profileInput($data);

        if ($name === '') {
            throw new DomainException('Nama wajib diisi.', 422, 'kiosk_name_required');
        }
        if ($email === null && $phone === null) {
            throw new DomainException('Isi email atau nomor telepon.', 422, 'kiosk_contact_required');
        }

        return DB::transaction(function () use ($lookup, $name, $email, $phone, $profile) {
            $user = User::query()->create([
                'name' => $name,
                'email' => $email,
                'phone' => $phone,
                'age' => $profile['age'],
                'origin' => $profile['origin'],
                'gender' => $profile['gender'],
                'password' => Str::password(16),
                'role' => UserRole::Visitor,
                'onboarding_completed_at' => now(),
            ]);

            $uid = (string) $lookup['rfid_uid'];
            $card = RfidMember::query()->findOrFail($lookup['rfid_member_id']);
            $card->update([
                'user_id' => $user->id,
                'is_active' => true,
            ]);

            Member::query()->create([
                'user_id' => $user->id,
                'display_name' => $user->name,
                'membership_tier' => 'standard',
                'balance' => $card->balance,
            ]);

            UserSetting::query()->create(['user_id' => $user->id]);
            Cart::query()->create(['user_id' => $user->id, 'currency' => 'IDR']);

            \App\Models\KioskCheckIn::query()
                ->where('rfid_member_id', $card->id)
                ->whereNull('user_id')
                ->update(['user_id' => $user->id]);
            \App\Models\KioskPresence::query()
                ->where('rfid_member_id', $card->id)
                ->whereNull('user_id')
                ->update(['user_id' => $user->id]);

            return $this->lookupRfid($uid);
        });
    }

    public function uploadPhoto(
        string $code,
        UploadedFile $photo,
        ?int $userId = null,
    ): RfidVerification {
        $payload = $this->verifyCode($code);

        if ($userId !== null && $userId !== $payload['user_id']) {
            throw new DomainException('user_id tidak cocok dengan kartu.', 422, 'kiosk_user_mismatch');
        }

        return DB::transaction(function () use ($payload, $photo) {
            $path = $photo->store('rfid/captures', 'local');

            $verification = $this->rfid->createVerification([
                'rfid_member_id' => $payload['rfid_member_id'],
                'user_id' => $payload['user_id'],
                'captured_image_path' => $path,
                'gate_opened' => true,
                'status' => 'verified',
                'message' => 'Kiosk photo captured successfully.',
                'verified_at' => now(),
            ]);

            return $verification->load(['rfidMember', 'user']);
        });
    }

    /**
     * @param  array<string, mixed>|null  $user
     * @return array<string, mixed>
     */
    private function lookupPayload(
        string $status,
        string $rfidUid,
        ?string $memberCode,
        ?bool $isActive,
        string $cardStatus,
        ?array $user,
        ?int $rfidMemberId = null,
        ?RfidMember $card = null,
    ): array {
        $resultCode = match ($status) {
            'registered' => 'MEMBER_FOUND',
            'issued' => 'CARD_READY',
            'unregistered' => 'RFID_NOT_REGISTERED',
            'inactive' => 'RFID_INACTIVE',
            'invalid' => 'RFID_INVALID',
            default => 'SERVER_ERROR',
        };

        $faceEnrolled = false;
        $userId = null;
        if (is_array($user) && isset($user['user_id'])) {
            $userId = (int) $user['user_id'];
            $faceEnrolled = UserFaceEnrollment::query()
                ->where('user_id', $userId)
                ->whereIn('pose', UserFaceEnrollment::poses())
                ->count() >= count(UserFaceEnrollment::poses());
        }

        $gate = $this->gateContext($card);
        $usable = in_array($status, ['registered', 'issued'], true);

        return [
            'status' => $status,
            'result_code' => $resultCode,
            'rfid_uid' => $rfidUid,
            'member_code' => $memberCode,
            'is_active' => $isActive,
            'card_status' => $cardStatus,
            'user' => $user,
            'rfid_member_id' => $rfidMemberId,
            'face_enrolled' => $faceEnrolled,
            'needs_face_enrollment' => false,
            'identity_linked' => $status === 'registered',
            'balance' => $gate['balance'],
            'balance_cap' => $this->balanceCap($status === 'registered'),
            'fare_amount' => $gate['fare_amount'],
            'location_id' => $gate['location_id'],
            'location_name' => $gate['location_name'],
            'can_enter' => $usable && $gate['can_enter'],
        ];
    }

    /**
     * @return array{user_id:int,name:string,email:?string,phone:?string}|null
     */
    private function userPayload(RfidMember $member): ?array
    {
        if ($member->user === null) {
            return null;
        }

        $member->loadMissing('user.member');

        return [
            'user_id' => (int) $member->user->id,
            'name' => $member->user->name,
            'email' => $member->user->email,
            'phone' => $member->user->phone,
            'age' => $member->user->age,
            'origin' => $member->user->origin,
            'gender' => $member->user->gender,
            'points' => (int) ($member->user->member?->points ?? 0),
            'balance' => (float) $member->balance,
        ];
    }

    /**
     * Fill name, age, origin, and gender for a card that is already linked.
     *
     * @param  array{name?:string,age?:int,origin?:string,gender?:string}  $data
     * @return array<string, mixed>
     */
    public function updateVisitorProfile(string $rfidUid, array $data): array
    {
        $lookup = $this->lookupRfid($rfidUid);
        if ($lookup['status'] !== 'registered' || empty($lookup['user']['user_id'])) {
            throw new DomainException('Kartu belum terhubung ke pengunjung.', 422, 'kiosk_profile_unlinked');
        }

        $name = trim((string) ($data['name'] ?? ''));
        if ($name === '') {
            throw new DomainException('Nama wajib diisi.', 422, 'kiosk_name_required');
        }
        $profile = $this->profileInput($data, required: true);

        $user = User::query()->findOrFail((int) $lookup['user']['user_id']);
        $user->update([
            'name' => $name,
            'age' => $profile['age'],
            'origin' => $profile['origin'],
            'gender' => $profile['gender'],
        ]);
        $user->member?->update(['display_name' => $name]);

        return $this->lookupRfid((string) $lookup['rfid_uid']);
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array{age:?int,origin:?string,gender:?string}
     */
    private function profileInput(array $data, bool $required = false): array
    {
        $age = isset($data['age']) && $data['age'] !== '' ? (int) $data['age'] : null;
        $origin = $this->nullableString($data['origin'] ?? null);
        $gender = $this->nullableString($data['gender'] ?? null);

        if ($required && ($age === null || $age < 1 || $age > 120)) {
            throw new DomainException('Umur wajib diisi.', 422, 'kiosk_age_required');
        }
        if ($required && $origin === null) {
            throw new DomainException('Asal wajib diisi.', 422, 'kiosk_origin_required');
        }
        if ($required && ! in_array($gender, ['male', 'female'], true)) {
            throw new DomainException('Jenis kelamin wajib diisi.', 422, 'kiosk_gender_required');
        }
        if ($gender !== null && ! in_array($gender, ['male', 'female'], true)) {
            throw new DomainException('Jenis kelamin tidak dikenali.', 422, 'kiosk_gender_invalid');
        }

        return [
            'age' => $age,
            'origin' => $origin,
            'gender' => $gender,
        ];
    }

    /**
     * @return array{balance:float,fare_amount:float,location_id:?int,location_name:?string,can_enter:bool}
     */
    private function gateContext(?RfidMember $card): array
    {
        $location = KioskLocation::query()->where('is_active', true)->orderBy('id')->first();
        $fare = (float) ($location->fare_amount ?? 0);
        $balance = (float) ($card?->balance ?? 0);
        $active = $card !== null && $card->is_active;

        return [
            'balance' => $balance,
            'fare_amount' => $fare,
            'location_id' => $location?->id,
            'location_name' => $location?->name,
            'can_enter' => $active && (int) round($balance * 100) >= (int) round($fare * 100),
        ];
    }

    private function balanceCap(bool $identityLinked): float
    {
        $key = $identityLinked ? 'kiosk.registered_balance_cap' : 'kiosk.anonymous_balance_cap';

        return (float) config($key, $identityLinked ? 10000000 : 1000000);
    }

    private function nullableString(mixed $value): ?string
    {
        if ($value === null) {
            return null;
        }
        $trimmed = trim((string) $value);

        return $trimmed === '' ? null : $trimmed;
    }

    private function isValidUidFormat(string $code): bool
    {
        if (strlen($code) < 4 || strlen($code) > 64) {
            return false;
        }

        return (bool) preg_match('/^[A-Za-z0-9\-_:]+$/', $code);
    }

    private function assertUidFormat(string $code): void
    {
        if (! $this->isValidUidFormat($code)) {
            throw new DomainException('Format RFID UID tidak valid.', 422, 'kiosk_invalid_uid');
        }
    }

    private function normalizeCode(string $raw): string
    {
        $raw = trim($raw);
        if ($raw === '') {
            throw new DomainException('Kode kosong.', 422, 'kiosk_empty_code');
        }

        // Support QR payloads like {"type":"wanderdesa_member","uid":"0182120545"}
        // (also accepts legacy type "kutuku_member")
        if (str_starts_with($raw, '{')) {
            $json = json_decode($raw, true);
            if (is_array($json)) {
                $raw = (string) ($json['uid'] ?? $json['rfid_uid'] ?? $json['member_code'] ?? $json['code'] ?? $raw);
            }
        }

        // Support deep-link style: wanderdesa://member/0182120545
        // (also accepts legacy kutuku://member/...)
        if (str_contains($raw, '/')) {
            $parts = preg_split('#[/?&=]#', $raw) ?: [];
            $candidate = end($parts);
            if (is_string($candidate) && $candidate !== '') {
                $raw = $candidate;
            }
        }

        return trim($raw);
    }
}
