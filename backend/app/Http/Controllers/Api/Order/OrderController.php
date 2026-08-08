<?php

namespace App\Http\Controllers\Api\Order;

use App\Http\Controllers\Controller;
use App\Http\Resources\OrderResource;
use App\Models\Order;
use App\Services\OrderService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function __construct(private readonly OrderService $orders)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $paginator = $this->orders->active($request->user(), (int) $request->integer('per_page', 15));

        return ApiResponse::resource(OrderResource::collection($paginator));
    }

    public function history(Request $request): JsonResponse
    {
        $paginator = $this->orders->history($request->user(), (int) $request->integer('per_page', 15));

        return ApiResponse::resource(OrderResource::collection($paginator));
    }

    public function show(Request $request, Order $order): JsonResponse
    {
        $this->authorize('view', $order);

        return ApiResponse::resource(
            new OrderResource($this->orders->show($request->user(), $order->id)),
        );
    }

    public function track(Request $request, Order $order): JsonResponse
    {
        $this->authorize('view', $order);

        return ApiResponse::resource(
            new OrderResource($this->orders->track($request->user(), $order->id)),
        );
    }

    public function cancel(Request $request, Order $order): JsonResponse
    {
        $this->authorize('cancel', $order);

        return ApiResponse::resource(
            new OrderResource($this->orders->cancel($request->user(), $order->id)),
            'Order cancelled',
        );
    }
}