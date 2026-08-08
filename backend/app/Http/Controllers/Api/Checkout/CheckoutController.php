<?php

namespace App\Http\Controllers\Api\Checkout;

use App\Http\Controllers\Controller;
use App\Http\Requests\Checkout\CheckoutRequest;
use App\Http\Resources\OrderResource;
use App\Services\CheckoutService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;

class CheckoutController extends Controller
{
    public function __construct(private readonly CheckoutService $checkout)
    {
    }

    public function __invoke(CheckoutRequest $request): JsonResponse
    {
        $order = $this->checkout->checkout($request->user(), $request->validated());

        return ApiResponse::resource(new OrderResource($order), 'Order placed successfully', 201);
    }
}