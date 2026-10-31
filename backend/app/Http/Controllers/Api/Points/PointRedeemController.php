<?php

namespace App\Http\Controllers\Api\Points;

use App\Http\Controllers\Controller;
use App\Http\Resources\MemberResource;
use App\Services\WalletService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PointRedeemController extends Controller
{
    public function __construct(private readonly WalletService $wallet)
    {
    }

    /**
     * POST /api/v1/points/redeem
     * Body: { "points": 100 }
     */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'points' => ['required', 'integer', 'min:1'],
        ]);

        $member = $this->wallet->redeemPoints($request->user(), (int) $data['points']);
        $rate = max(1, (int) config('kiosk.points_per_currency', 100));

        return ApiResponse::success([
            'member' => MemberResource::make($member)->resolve(),
            'points_per_currency' => $rate,
        ], 'Poin berhasil ditukar menjadi diskon.');
    }
}
