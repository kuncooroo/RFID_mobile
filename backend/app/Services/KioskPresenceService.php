<?php

namespace App\Services;

use App\Exceptions\DomainException;
use App\Models\KioskCheckIn;
use App\Models\KioskLocation;
use App\Models\KioskPointLedger;
use App\Models\KioskPresence;
use App\Models\Member;
use App\Models\WalletLedger;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;

/**
 * Presence proof + check-in + loyalty points for kiosk (no face-AI in this phase).
 */
class KioskPresenceService
{
    public function __construct(private readonly KioskService $kiosk)
    {
    }

    /**
     * @return array<string, mixed>
     */
    public function recordPresence(
        string $rfidUid,
        UploadedFile $photo,
        ?int $locationId = null,
        ?string $deviceId = null,
    ): array {
        $bound = $this->kiosk->verifyCode($rfidUid);
        $location = $this->resolveLocation($locationId ?? config('kiosk.default_location_id'));

        $path = $photo->store('kiosk/presences', 'local');

        $presence = KioskPresence::query()->create([
            'user_id' => $bound['user_id'],
            'rfid_member_id' => $bound['rfid_member_id'],
            'location_id' => $location->id,
            'device_id' => $deviceId,
            'photo_path' => $path,
            'status' => 'verified',
            'captured_at' => now(),
        ]);

        return [
            'id' => $presence->id,
            'user_id' => $presence->user_id,
            'rfid_id' => $presence->rfid_member_id,
            'location_id' => $presence->location_id,
            'device_id' => $presence->device_id,
            'photo_path' => $presence->photo_path,
            'status' => 'VERIFIED',
            'captured_at' => $presence->captured_at?->toIso8601String(),
        ];
    }

    /**
     * Gate passage: card must be bound, saldo must cover the location fare.
     * A granted tap debits saldo, stores an optional capture, and awards points.
     *
     * @return array<string, mixed>
     */
    public function recordVisit(
        string $rfidUid,
        ?int $locationId = null,
        ?string $deviceId = null,
        ?UploadedFile $photo = null,
    ): array {
        $bound = $this->kiosk->verifyCode($rfidUid);
        $location = $this->resolveLocation($locationId ?? config('kiosk.default_location_id'));
        $cooldown = max(0, (int) config('kiosk.scan_cooldown_seconds', 60));
        $reward = (int) config('kiosk.checkin_points', 10);

        return DB::transaction(function () use ($bound, $location, $deviceId, $photo, $cooldown, $reward) {
            $latest = KioskCheckIn::query()
                ->where('user_id', $bound['user_id'])
                ->where('location_id', $location->id)
                ->where('status', 'success')
                ->orderByDesc('checked_in_at')
                ->lockForUpdate()
                ->first();

            if ($latest && $cooldown > 0 && $latest->checked_in_at?->gt(now()->subSeconds($cooldown))) {
                $member = $this->memberFor($bound);

                return $this->passagePayload(
                    checkIn: $latest,
                    member: $member,
                    bound: $bound,
                    location: $location,
                    deviceId: $deviceId,
                    duplicate: true,
                );
            }

            return $this->settleGate($bound, $location, $deviceId, $photo, null, $reward);
        });
    }

    /**
     * @return array<string, mixed>
     */
    public function checkIn(int $presenceId, string $rfidUid): array
    {
        $bound = $this->kiosk->verifyCode($rfidUid);
        $presence = KioskPresence::query()->findOrFail($presenceId);

        if ((int) $presence->user_id !== (int) $bound['user_id']) {
            throw new DomainException('Presence tidak cocok dengan kartu RFID.', 422, 'kiosk_presence_mismatch');
        }

        if ($presence->status !== 'verified') {
            throw new DomainException('Presence belum terverifikasi.', 422, 'kiosk_presence_unverified');
        }

        $location = $this->resolveLocation((int) $presence->location_id);
        $reward = (int) config('kiosk.checkin_points', 10);

        return DB::transaction(function () use ($presence, $bound, $location, $reward) {
            $existing = KioskCheckIn::query()
                ->where('presence_id', $presence->id)
                ->where('status', 'success')
                ->lockForUpdate()
                ->first();

            if ($existing) {
                return $this->passagePayload(
                    checkIn: $existing,
                    member: $this->memberFor($bound),
                    bound: $bound,
                    location: $location,
                    deviceId: $presence->device_id,
                    duplicate: true,
                );
            }

            return $this->settleGate($bound, $location, $presence->device_id, null, (int) $presence->id, $reward);
        });
    }

    /**
     * @param  array{user_id:int,name:string,rfid_uid:string,member_code:string,rfid_member_id:int}  $bound
     * @return array<string, mixed>
     */
    private function settleGate(
        array $bound,
        KioskLocation $location,
        ?string $deviceId,
        ?UploadedFile $photo,
        ?int $presenceId,
        int $reward,
    ): array {
        $member = Member::query()->where('user_id', $bound['user_id'])->lockForUpdate()->first();
        if (! $member) {
            $member = Member::query()->create([
                'user_id' => $bound['user_id'],
                'display_name' => $bound['name'],
                'balance' => 0,
                'points' => 0,
            ]);
        }

        $fareCents = $this->cents($location->fare_amount);
        $balanceCents = $this->cents($member->balance);

        if ($balanceCents < $fareCents) {
            $denied = KioskCheckIn::query()->create([
                'user_id' => $bound['user_id'],
                'rfid_member_id' => $bound['rfid_member_id'],
                'location_id' => $location->id,
                'presence_id' => $presenceId,
                'status' => 'denied',
                'points_awarded' => 0,
                'amount_charged' => 0,
                'balance_after' => $member->balance,
                'deny_reason' => 'insufficient_balance',
                'checked_in_at' => now(),
            ]);

            return $this->passagePayload(
                checkIn: $denied,
                member: $member,
                bound: $bound,
                location: $location,
                deviceId: $deviceId,
                duplicate: false,
            );
        }

        if ($photo !== null) {
            $path = $photo->store('kiosk/presences', 'local');
            $presence = KioskPresence::query()->create([
                'user_id' => $bound['user_id'],
                'rfid_member_id' => $bound['rfid_member_id'],
                'location_id' => $location->id,
                'device_id' => $deviceId,
                'photo_path' => $path,
                'status' => 'verified',
                'captured_at' => now(),
            ]);
            $presenceId = (int) $presence->id;
        }

        $nextBalance = ($balanceCents - $fareCents) / 100;
        $member->balance = number_format($nextBalance, 2, '.', '');
        $member->points = (int) $member->points + $reward;
        $member->save();

        $checkIn = KioskCheckIn::query()->create([
            'user_id' => $bound['user_id'],
            'rfid_member_id' => $bound['rfid_member_id'],
            'location_id' => $location->id,
            'presence_id' => $presenceId,
            'status' => 'success',
            'points_awarded' => $reward,
            'amount_charged' => number_format($fareCents / 100, 2, '.', ''),
            'balance_after' => $member->balance,
            'checked_in_at' => now(),
        ]);

        if ($fareCents > 0) {
            WalletLedger::query()->create([
                'user_id' => $bound['user_id'],
                'check_in_id' => $checkIn->id,
                'delta' => number_format(-1 * $fareCents / 100, 2, '.', ''),
                'balance_after' => $member->balance,
                'reason' => 'gate_debit',
            ]);
        }

        if ($reward > 0) {
            KioskPointLedger::query()->create([
                'user_id' => $bound['user_id'],
                'check_in_id' => $checkIn->id,
                'delta' => $reward,
                'balance_after' => (int) $member->points,
                'reason' => 'kiosk_visit',
            ]);
        }

        return $this->passagePayload(
            checkIn: $checkIn,
            member: $member,
            bound: $bound,
            location: $location,
            deviceId: $deviceId,
            duplicate: false,
        );
    }

    /**
     * @param  array{user_id:int,name:string,member_code:string,rfid_member_id:int}  $bound
     * @return array<string, mixed>
     */
    private function passagePayload(
        KioskCheckIn $checkIn,
        Member $member,
        array $bound,
        KioskLocation $location,
        ?string $deviceId,
        bool $duplicate,
    ): array {
        $granted = $checkIn->status === 'success';
        $resultCode = match (true) {
            $duplicate => 'ALREADY_CHECKED_IN',
            $granted => 'GATE_GRANTED',
            $checkIn->deny_reason === 'insufficient_balance' => 'INSUFFICIENT_BALANCE',
            default => 'GATE_DENIED',
        };

        return [
            'success' => $granted,
            'granted' => $granted,
            'duplicate' => $duplicate,
            'result_code' => $resultCode,
            'id' => $checkIn->id,
            'user_id' => $checkIn->user_id,
            'rfid_id' => $checkIn->rfid_member_id,
            'location_id' => $checkIn->location_id,
            'location_name' => $location->name,
            'device_id' => $deviceId,
            'presence_id' => $checkIn->presence_id,
            'checked_in_at' => $checkIn->checked_in_at?->toIso8601String(),
            'status' => $granted ? 'SUCCESS' : 'DENIED',
            'deny_reason' => $checkIn->deny_reason,
            'points_awarded' => (int) $checkIn->points_awarded,
            'points_balance' => (int) $member->points,
            'amount_charged' => (float) $checkIn->amount_charged,
            'fare_amount' => (float) $location->fare_amount,
            'wallet_balance' => (float) $member->balance,
            'already_checked_in_today' => $duplicate,
            'member_name' => $bound['name'],
            'member_code' => $bound['member_code'],
            'has_photo' => $checkIn->presence_id !== null,
            'user' => [
                'user_id' => $bound['user_id'],
                'name' => $bound['name'],
                'member_code' => $bound['member_code'],
            ],
            'visit' => [
                'id' => $checkIn->id,
                'checked_in_at' => $checkIn->checked_in_at?->toIso8601String(),
                'status' => $checkIn->status,
            ],
            'points' => [
                'earned' => $duplicate ? 0 : (int) $checkIn->points_awarded,
                'balance' => (int) $member->points,
            ],
            'wallet' => [
                'charged' => $duplicate ? 0 : (float) $checkIn->amount_charged,
                'balance' => (float) $member->balance,
            ],
        ];
    }

    /**
     * @param  array{user_id:int,name:string}  $bound
     */
    private function memberFor(array $bound): Member
    {
        return Member::query()->firstOrCreate(
            ['user_id' => $bound['user_id']],
            ['display_name' => $bound['name'], 'balance' => 0, 'points' => 0],
        );
    }

    private function cents(mixed $amount): int
    {
        return (int) round(((float) $amount) * 100);
    }

    private function resolveLocation(?int $locationId): KioskLocation
    {
        $query = KioskLocation::query()->where('is_active', true);
        $location = $locationId
            ? $query->where('id', $locationId)->first()
            : $query->orderBy('id')->first();

        if (! $location) {
            throw new DomainException('Lokasi kiosk tidak tersedia.', 422, 'kiosk_location_missing');
        }

        return $location;
    }
}
