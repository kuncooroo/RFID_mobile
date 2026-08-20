<?php

namespace App\Services;

use App\Exceptions\DomainException;
use App\Models\User;
use App\Models\UserFaceEnrollment;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

/**
 * Three-pose face enrollment at first registration only.
 */
class KioskFaceEnrollmentService
{
    public function __construct(private readonly KioskService $kiosk)
    {
    }

    /**
     * @param  array{front:UploadedFile,right:UploadedFile,left:UploadedFile}  $photos
     * @return array<string, mixed>
     */
    public function enroll(string $rfidUid, array $photos): array
    {
        $bound = $this->kiosk->verifyCode($rfidUid);

        foreach (UserFaceEnrollment::poses() as $pose) {
            if (! isset($photos[$pose]) || ! $photos[$pose] instanceof UploadedFile) {
                throw new DomainException(
                    "Foto pose {$pose} wajib diunggah.",
                    422,
                    'kiosk_face_pose_required',
                );
            }
        }

        return DB::transaction(function () use ($bound, $photos) {
            $user = User::query()->findOrFail($bound['user_id']);
            $saved = [];

            foreach (UserFaceEnrollment::poses() as $pose) {
                /** @var UploadedFile $file */
                $file = $photos[$pose];
                $path = $file->store("rfid/enrollments/{$user->id}", 'local');

                $existing = UserFaceEnrollment::query()
                    ->where('user_id', $user->id)
                    ->where('pose', $pose)
                    ->first();

                if ($existing && $existing->image_path) {
                    Storage::disk('local')->delete($existing->image_path);
                }

                $row = UserFaceEnrollment::query()->updateOrCreate(
                    ['user_id' => $user->id, 'pose' => $pose],
                    [
                        'image_path' => $path,
                        'enrolled_at' => now(),
                    ],
                );

                $saved[$pose] = [
                    'id' => $row->id,
                    'pose' => $row->pose,
                    'image_path' => $row->image_path,
                    'enrolled_at' => $row->enrolled_at?->toIso8601String(),
                ];
            }

            return [
                'user_id' => $user->id,
                'name' => $user->name,
                'rfid_uid' => $bound['rfid_uid'],
                'member_code' => $bound['member_code'],
                'face_enrolled' => true,
                'poses' => $saved,
            ];
        });
    }

    public function isEnrolled(int $userId): bool
    {
        $count = UserFaceEnrollment::query()
            ->where('user_id', $userId)
            ->whereIn('pose', UserFaceEnrollment::poses())
            ->count();

        return $count >= count(UserFaceEnrollment::poses());
    }
}
