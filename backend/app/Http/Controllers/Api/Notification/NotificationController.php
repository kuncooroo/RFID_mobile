<?php

namespace App\Http\Controllers\Api\Notification;

use App\Http\Controllers\Controller;
use App\Http\Resources\NotificationResource;
use App\Services\NotificationService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function __construct(private readonly NotificationService $notifications)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $paginator = $this->notifications->list($request->user(), (int) $request->integer('per_page', 20));

        return ApiResponse::resource(NotificationResource::collection($paginator));
    }

    public function markRead(Request $request, int $notification): JsonResponse
    {
        $item = $this->notifications->markRead($request->user(), $notification);

        return ApiResponse::resource(new NotificationResource($item), 'Notification marked as read');
    }

    public function markAllRead(Request $request): JsonResponse
    {
        $this->notifications->markAllRead($request->user());

        return ApiResponse::success(null, 'All notifications marked as read');
    }
}