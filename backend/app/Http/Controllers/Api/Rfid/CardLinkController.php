<?php

namespace App\Http\Controllers\Api\Rfid;

use App\Http\Controllers\Controller;
use App\Models\RfidMember;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CardLinkController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $card = $request->user()->rfidMember;

        return ApiResponse::success([
            'linked' => $card !== null && $card->is_active,
            'card_number' => $card?->card_number,
            'member_code' => $card?->member_code,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'card_number' => ['required', 'string', 'max:32'],
        ]);

        $number = preg_replace('/\D/', '', (string) $data['card_number']) ?? '';
        if (strlen($number) !== 16) {
            return ApiResponse::error('Nomor kartu harus 16 digit.', 422, null, 'card_number_invalid');
        }

        $user = $request->user();
        $card = RfidMember::query()->where('card_number', $number)->first();
        if ($card === null) {
            return ApiResponse::error('Nomor kartu tidak ditemukan.', 404, null, 'card_not_found');
        }
        if (! $card->is_active) {
            return ApiResponse::error('Kartu ini nonaktif.', 422, null, 'card_inactive');
        }
        if ($card->user_id !== null && (int) $card->user_id !== (int) $user->id) {
            return ApiResponse::error('Kartu ini sudah terhubung ke akun lain.', 409, null, 'card_taken');
        }

        $current = $user->rfidMember;
        if ($current !== null && (int) $current->id !== (int) $card->id) {
            return ApiResponse::error('Akun ini sudah punya kartu lain.', 409, null, 'account_has_card');
        }

        $card->update([
            'user_id' => $user->id,
            'is_active' => true,
        ]);

        return ApiResponse::success([
            'linked' => true,
            'card_number' => $card->card_number,
            'member_code' => $card->member_code,
        ], 'Kartu terhubung.');
    }
};
