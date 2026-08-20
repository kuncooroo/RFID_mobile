<?php

namespace App\Services;

use App\Exceptions\DomainException;
use App\Models\KioskCheckIn;
use App\Models\KioskLocation;
use App\Models\KioskPointLedger;
use App\Models\KioskPresence;
use App\Models\Member;
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

        $reward = (int) config('kiosk.checkin_points', 10);

        return DB::transaction(function () use ($presence, $bound, $reward) {
            $already = KioskCheckIn::query()
                ->where('user_id', $presence->user_id)
                ->where('location_id', $presence->location_id)
                ->whereDate('checked_in_at', now()->toDateString())
                ->where('status', 'success')
                ->exists();

            $points = $already ? 0 : $reward;

            $checkIn = KioskCheckIn::query()->create([
                'user_id' => $presence->user_id,
                'rfid_member_id' => $bound['rfid_member_id'],
                'location_id' => $presence->location_id,
                'presence_id' => $presence->id,
                'status' => 'success',
                'points_awarded' => $points,
                'checked_in_at' => now(),
            ]);

            $member = Member::query()->firstOrCreate(
                ['user_id' => $presence->user_id],
                ['display_name' => $bound['name']],
            );

            if ($points > 0) {
                $member->increment('points', $points);
                $member->refresh();
                KioskPointLedger::query()->create([
                    'user_id' => $presence->user_id,
                    'check_in_id' => $checkIn->id,
                    'delta' => $points,
                    'balance_after' => (int) $member->points,
                    'reason' => 'kiosk_check_in',
                ]);
            } else {
                $member->refresh();
            }

            return [
                'id' => $checkIn->id,
                'user_id' => $checkIn->user_id,
                'rfid_id' => $checkIn->rfid_member_id,
                'location_id' => $checkIn->location_id,
                'presence_id' => $checkIn->presence_id,
                'checked_in_at' => $checkIn->checked_in_at?->toIso8601String(),
                'status' => 'SUCCESS',
                'points_awarded' => $points,
                'points_balance' => (int) $member->points,
                'already_checked_in_today' => $already,
                'member_name' => $bound['name'],
                'member_code' => $bound['member_code'],
            ];
        });
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
