<?php

namespace App\Http\Controllers\Api\Kiosk;

use App\Http\Controllers\Controller;
use App\Services\KioskService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class KioskController extends Controller
{
    public function __construct(private readonly KioskService $kiosk)
    {
    }

    /**
     * POST /api/v1/kiosk/verify
     * Body: { "code": "0182120545" }  // RFID UID, member_code, or QR payload
     */
    public function verify(Request $request): JsonResponse
    {
        $data = $request->validate([
            'code' => ['required', 'string', 'max:255'],
            'rfid_uid' => ['nullable', 'string', 'max:255'],
        ]);

        $code = $data['code'] ?? $data['rfid_uid'];
        $result = $this->kiosk->verifyCode((string) $code);

        return ApiResponse::success($result, 'Kartu valid. Siap mengambil foto.');
    }

    /**
     * POST /api/v1/kiosk/upload-photo
     * multipart: photo (jpg), code|rfid_uid, optional user_id
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
}
