<?php

namespace App\Http\Controllers\Api\Kiosk;

use App\Http\Controllers\Controller;
use App\Services\KioskFaceEnrollmentService;
use App\Services\KioskPresenceService;
use App\Services\KioskService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class KioskController extends Controller
{
    public function __construct(
        private readonly KioskService $kiosk,
        private readonly KioskPresenceService $presence,
        private readonly KioskFaceEnrollmentService $faceEnrollment,
    ) {
    }

    /**
     * GET /api/v1/kiosk/health
     */
    public function health(): JsonResponse
    {
        return ApiResponse::success($this->kiosk->health(), 'Kiosk API ready');
    }

    /**
     * POST /api/v1/kiosk/rfid/verify
     * Body: { "rfid_uid": "..." }
     */
    public function lookupRfid(Request $request): JsonResponse
    {
        $data = $request->validate([
            'rfid_uid' => ['nullable', 'string', 'max:255'],
            'code' => ['nullable', 'string', 'max:255'],
        ]);

        $code = trim((string) ($data['rfid_uid'] ?? $data['code'] ?? ''));
        if ($code === '') {
            return ApiResponse::error('rfid_uid wajib diisi.', 422, null, 'kiosk_missing_code');
        }

        $result = $this->kiosk->lookupRfid($code);
        $message = match ($result['result_code'] ?? $result['status']) {
            'MEMBER_FOUND', 'registered' => 'Kartu terdaftar.',
            'RFID_NOT_REGISTERED', 'unregistered' => 'Kartu belum terdaftar.',
            'RFID_INACTIVE', 'inactive' => 'Kartu nonaktif.',
            'RFID_INVALID', 'invalid' => 'Format kartu tidak valid.',
            default => 'Status kartu tidak dikenali.',
        };

        return ApiResponse::success($result, $message);
    }

    /**
     * POST /api/v1/kiosk/verify
     * Body: { "code": "0182120545" }  // RFID UID, member_code, or QR payload
     */
    public function verify(Request $request): JsonResponse
    {
        $data = $request->validate([
            'code' => ['nullable', 'string', 'max:255'],
            'rfid_uid' => ['nullable', 'string', 'max:255'],
        ]);

        $code = trim((string) ($data['code'] ?? $data['rfid_uid'] ?? ''));
        if ($code === '') {
            return ApiResponse::error('code atau rfid_uid wajib diisi.', 422, null, 'kiosk_missing_code');
        }

        $result = $this->kiosk->verifyCode($code);

        return ApiResponse::success($result, 'Kartu valid.');
    }

    /**
     * POST /api/v1/kiosk/register
     */
    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'rfid_uid' => ['required', 'string', 'max:255'],
            'name' => ['required', 'string', 'max:120'],
            'email' => ['nullable', 'email', 'max:190', Rule::unique('users', 'email')],
            'phone' => ['nullable', 'string', 'max:40', Rule::unique('users', 'phone')],
        ]);

        if (empty($data['email']) && empty($data['phone'])) {
            return ApiResponse::error(
                'Isi email atau nomor telepon.',
                422,
                ['email' => ['Provide at least an email or phone.']],
                'kiosk_contact_required',
            );
        }

        $result = $this->kiosk->registerVisitor($data['rfid_uid'], $data);

        return ApiResponse::created($result, 'Registrasi berhasil. Kartu RFID terhubung.');
    }

    /**
     * POST /api/v1/kiosk/face-enrollment
     * multipart: rfid_uid, front, right, left
     */
    public function enrollFace(Request $request): JsonResponse
    {
        $data = $request->validate([
            'rfid_uid' => ['required', 'string', 'max:255'],
            'front' => ['required', 'file', 'image', 'max:10240'],
            'right' => ['required', 'file', 'image', 'max:10240'],
            'left' => ['required', 'file', 'image', 'max:10240'],
        ]);

        $result = $this->faceEnrollment->enroll($data['rfid_uid'], [
            'front' => $request->file('front'),
            'right' => $request->file('right'),
            'left' => $request->file('left'),
        ]);

        return ApiResponse::created($result, 'Face enrollment berhasil.');
    }

    /**
     * POST /api/v1/kiosk/visit
     * Body: { "rfid_uid": "...", "location_id"?: int, "device_id"?: string }
     * RFID visit without face capture.
     */
    public function visit(Request $request): JsonResponse
    {
        $data = $request->validate([
            'rfid_uid' => ['required', 'string', 'max:255'],
            'location_id' => ['nullable', 'integer', 'exists:kiosk_locations,id'],
            'device_id' => ['nullable', 'string', 'max:120'],
        ]);

        $result = $this->presence->recordVisit(
            $data['rfid_uid'],
            isset($data['location_id']) ? (int) $data['location_id'] : null,
            $data['device_id'] ?? null,
        );

        $message = match ($result['result_code'] ?? '') {
            'ALREADY_CHECKED_IN' => 'Sudah check-in baru-baru ini.',
            'ALREADY_CHECKED_IN_TODAY' => 'Kunjungan tercatat. Poin harian sudah diambil.',
            default => 'Kunjungan tercatat.',
        };

        return ApiResponse::success($result, $message);
    }

    /**
     * POST /api/v1/kiosk/upload-photo
     * multipart: photo (jpg), code|rfid_uid, optional user_id
     * @deprecated Prefer face-enrollment for identity photos.
     */
    public function uploadPhoto(Request $request): JsonResponse
    {
        $data = $request->validate([
            'photo' => ['required', 'file', 'image', 'max:10240'],
            'code' => ['nullable', 'string', 'max:255'],
            'rfid_uid' => ['nullable', 'string', 'max:255'],
            'user_id' => ['nullable', 'integer', 'exists:users,id'],
        ]);

        $code = trim((string) ($data['code'] ?? $data['rfid_uid'] ?? ''));
        if ($code === '') {
            return ApiResponse::error('code atau rfid_uid wajib diisi.', 422, null, 'kiosk_missing_code');
        }

        $verification = $this->kiosk->uploadPhoto(
            $code,
            $request->file('photo'),
            isset($data['user_id']) ? (int) $data['user_id'] : null,
        );

        return ApiResponse::created([
            'id' => $verification->id,
            'user_id' => $verification->user_id,
            'rfid_uid' => $verification->rfidMember?->rfid_uid,
            'member_code' => $verification->rfidMember?->member_code,
            'status' => $verification->status,
            'captured_image_path' => $verification->captured_image_path,
            'verified_at' => optional($verification->verified_at)?->toIso8601String(),
        ], 'Foto berhasil diunggah ke galeri.');
    }

    /**
     * POST /api/v1/kiosk/presence
     * multipart: photo, rfid_uid, optional location_id, device_id, captured_at
     */
    public function recordPresence(Request $request): JsonResponse
    {
        $data = $request->validate([
            'photo' => ['required', 'file', 'image', 'max:10240'],
            'rfid_uid' => ['required', 'string', 'max:255'],
            'location_id' => ['nullable', 'integer', 'exists:kiosk_locations,id'],
            'device_id' => ['nullable', 'string', 'max:120'],
            'captured_at' => ['nullable', 'date'],
        ]);

        $result = $this->presence->recordPresence(
            $data['rfid_uid'],
            $request->file('photo'),
            isset($data['location_id']) ? (int) $data['location_id'] : null,
            $data['device_id'] ?? null,
        );

        return ApiResponse::created($result, 'Presence tercatat.');
    }

    /**
     * POST /api/v1/kiosk/check-in
     * Body: { "presence_id": 1, "rfid_uid": "..." }
     */
    public function checkIn(Request $request): JsonResponse
    {
        $data = $request->validate([
            'presence_id' => ['required', 'integer', 'exists:kiosk_presences,id'],
            'rfid_uid' => ['required', 'string', 'max:255'],
        ]);

        $result = $this->presence->checkIn((int) $data['presence_id'], $data['rfid_uid']);

        return ApiResponse::created($result, 'Check-in berhasil.');
    }
}
