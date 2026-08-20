<?php

namespace App\Services;

use App\Contracts\Repositories\RfidRepositoryInterface;
use App\Enums\UserRole;
use App\Exceptions\DomainException;
use App\Models\Cart;
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
            );
        }

        if ($member->user_id === null) {
            return $this->lookupPayload(
                status: 'unregistered',
                rfidUid: $member->rfid_uid,
                memberCode: $member->member_code,
                isActive: true,
                cardStatus: 'unbound',
                user: null,
                rfidMemberId: (int) $member->id,
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
        );
    }

    /**
     * Resolve an active RFID / QR code to a bound visitor.
     *
     * @return array{user_id:int,name:string,rfid_uid:string,member_code:string,rfid_member_id:int}
     */
    public function verifyCode(string $code): array
    {
        $lookup = $this->lookupRfid($code);

        return match ($lookup['status']) {
            'inactive' => throw new DomainException('Kartu RFID nonaktif.', 422, 'kiosk_member_inactive'),
            'unregistered' => throw new DomainException(
                'Kartu belum terdaftar. Silakan registrasi di kiosk.',
                422,
                'kiosk_member_unbound',
            ),
            'registered' => [
                'user_id' => (int) $lookup['user']['user_id'],
                'name' => (string) $lookup['user']['name'],
                'rfid_uid' => (string) $lookup['rfid_uid'],
                'member_code' => (string) ($lookup['member_code'] ?? ''),
                'rfid_member_id' => (int) ($lookup['rfid_member_id'] ?? 0),
            ],
            default => throw new DomainException('Kartu / QR tidak dikenali.', 404, 'kiosk_member_not_found'),
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

        $name = trim((string) ($data['name'] ?? ''));
        $email = $this->nullableString($data['email'] ?? null);
        $phone = $this->nullableString($data['phone'] ?? null);

        if ($name === '') {
            throw new DomainException('Nama wajib diisi.', 422, 'kiosk_name_required');
        }
        if ($email === null && $phone === null) {
            throw new DomainException('Isi email atau nomor telepon.', 422, 'kiosk_contact_required');
        }

        return DB::transaction(function () use ($lookup, $name, $email, $phone) {
            $user = User::query()->create([
                'name' => $name,
                'email' => $email,
                'phone' => $phone,
                'password' => Str::password(16),
                'role' => UserRole::Visitor,
                'onboarding_completed_at' => now(),
            ]);

            Member::query()->create([
                'user_id' => $user->id,
                'display_name' => $user->name,
                'membership_tier' => 'standard',
            ]);

            UserSetting::query()->create(['user_id' => $user->id]);
            Cart::query()->create(['user_id' => $user->id, 'currency' => 'USD']);

            $uid = (string) $lookup['rfid_uid'];
            $existingId = $lookup['rfid_member_id'] ?? null;

            if ($existingId) {
                $card = RfidMember::query()->findOrFail($existingId);
                $card->update([
                    'user_id' => $user->id,
                    'is_active' => true,
                ]);
            } else {
                RfidMember::query()->create([
                    'user_id' => $user->id,
                    'member_code' => 'MEM-'.str_pad((string) $user->id, 5, '0', STR_PAD_LEFT),
                    'rfid_uid' => $uid,
                    'is_active' => true,
                ]);
            }

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
    ): array {
        $resultCode = match ($status) {
            'registered' => 'MEMBER_FOUND',
            'unregistered' => 'RFID_NOT_REGISTERED',
            'inactive' => 'RFID_INACTIVE',
            'invalid' => 'RFID_INVALID',
            default => 'SERVER_ERROR',
        };

        $faceEnrolled = false;
        if (is_array($user) && isset($user['user_id'])) {
            $faceEnrolled = UserFaceEnrollment::query()
                ->where('user_id', (int) $user['user_id'])
                ->whereIn('pose', UserFaceEnrollment::poses())
                ->count() >= count(UserFaceEnrollment::poses());
        }

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
            'needs_face_enrollment' => $status === 'registered' && ! $faceEnrolled,
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
            'points' => (int) ($member->user->member?->points ?? 0),
        ];
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

        // Support QR payloads like {"type":"kutuku_member","uid":"0182120545"}
        if (str_starts_with($raw, '{')) {
            $json = json_decode($raw, true);
            if (is_array($json)) {
                $raw = (string) ($json['uid'] ?? $json['rfid_uid'] ?? $json['member_code'] ?? $json['code'] ?? $raw);
            }
        }

        // Support deep-link style: kutuku://member/0182120545
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
