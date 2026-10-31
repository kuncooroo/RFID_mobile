<?php

namespace App\Http\Controllers\Api\Experience;

use App\Http\Controllers\Controller;
use App\Models\KioskCheckIn;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ExperienceController extends Controller
{
    /**
     * GET /api/v1/experiences
     * Granted gate passages for the signed-in visitor.
     */
    public function index(Request $request): JsonResponse
    {
        $visits = KioskCheckIn::query()
            ->with(['location', 'presence'])
            ->where('user_id', $request->user()->id)
            ->where('status', 'success')
            ->orderByDesc('checked_in_at')
            ->orderByDesc('id')
            ->paginate(20);

        $data = $visits->getCollection()->map(function (KioskCheckIn $visit) {
            return [
                'id' => $visit->id,
                'location_name' => $visit->location?->name,
                'checked_in_at' => $visit->checked_in_at?->toIso8601String(),
                'amount_charged' => (float) $visit->amount_charged,
                'balance_after' => $visit->balance_after !== null ? (float) $visit->balance_after : null,
                'points_awarded' => (int) $visit->points_awarded,
                'has_photo' => $visit->presence?->photo_path !== null,
            ];
        })->values();

        return ApiResponse::success($data->all(), 'Experiences loaded.', 200, [
            'current_page' => $visits->currentPage(),
            'per_page' => $visits->perPage(),
            'total' => $visits->total(),
            'last_page' => $visits->lastPage(),
        ]);
    }

    /**
     * GET /api/v1/experiences/{checkIn}/photo
     */
    public function photo(Request $request, KioskCheckIn $checkIn): StreamedResponse
    {
        abort_unless((int) $checkIn->user_id === (int) $request->user()->id, 404);
        abort_unless($checkIn->status === 'success', 404);

        $checkIn->loadMissing('presence');
        $path = $checkIn->presence?->photo_path;
        $disk = Storage::disk('local');
        abort_unless(is_string($path) && $path !== '' && $disk->exists($path), 404);

        return $disk->response($path);
    }
}
