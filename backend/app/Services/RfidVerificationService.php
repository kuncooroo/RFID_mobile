<?php

namespace App\Services;

use App\Contracts\Repositories\RfidRepositoryInterface;
use App\Exceptions\DomainException;
use App\Models\RfidVerification;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;

class RfidVerificationService
{
    public function __construct(private readonly RfidRepositoryInterface $rfid)
    {
    }

    public function verify(User $user, string $memberId, ?UploadedFile $image = null): RfidVerification
    {
        $member = $this->rfid->findActiveMember($memberId);

        if (! $member) {
            throw new DomainException('RFID member not found or inactive.', 404, 'rfid_member_not_found');
        }

        // Member card must belong to the authenticated user (or be unbound then claimable).
        if ($member->user_id !== null && $member->user_id !== $user->id) {
            throw new DomainException('RFID member does not belong to this account.', 403, 'rfid_forbidden');
        }

        return DB::transaction(function () use ($user, $member, $image) {
            if ($member->user_id === null) {
                $member->update(['user_id' => $user->id]);
            }

            $path = null;
            if ($image) {
                $path = $image->store('rfid/captures', 'local');
            }

            $verification = $this->rfid->createVerification([
                'rfid_member_id' => $member->id,
                'user_id' => $user->id,
                'captured_image_path' => $path,
                'gate_opened' => true,
                'status' => 'verified',
                'message' => 'Verification Successful! Gate Opening. Happy Shopping!',
                'verified_at' => now(),
            ]);

            return $verification->load('rfidMember');
        });
    }

    public function show(User $user, int $id): RfidVerification
    {
        $verification = RfidVerification::query()->with('rfidMember')->findOrFail($id);

        if ($verification->user_id !== $user->id) {
            throw new DomainException('Verification not found.', 404, 'verification_not_found');
        }

        return $verification;
    }
}
