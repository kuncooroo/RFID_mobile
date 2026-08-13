<?php

namespace App\Services;

use App\Contracts\Repositories\RfidRepositoryInterface;
use App\Exceptions\DomainException;
use App\Models\RfidVerification;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;

/**
 * Kiosk self-service flows — does not alter mobile verify ownership rules.
 */
class KioskService
{
    public function __construct(private readonly RfidRepositoryInterface $rfid)
    {
    }

    /**
     * Resolve an active RFID / QR code to a bound visitor.
     *
     * @return array{user_id:int,name:string,rfid_uid:string,member_code:string,rfid_member_id:int}
     */
    public function verifyCode(string $code): array
    {
        $code = $this->normalizeCode($code);
        $member = $this->rfid->findActiveMember($code);

        if (! $member) {
            throw new DomainException('Kartu / QR tidak dikenali atau nonaktif.', 404, 'kiosk_member_not_found');
        }

        if ($member->user_id === null) {
            throw new DomainException('Kartu belum terhubung ke pengunjung. Hubungi kasir.', 422, 'kiosk_member_unbound');
        }

        $member->loadMissing('user');

        return [
            'user_id' => (int) $member->user_id,
            'name' => $member->user?->name ?? 'Pengunjung',
            'rfid_uid' => $member->rfid_uid,
            'member_code' => $member->member_code,
            'rfid_member_id' => (int) $member->id,
        ];
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
