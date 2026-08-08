<?php

namespace App\Http\Controllers\Api\Checkout;

use App\Http\Controllers\Controller;
use App\Http\Requests\Checkout\StorePaymentMethodRequest;
use App\Http\Resources\PaymentMethodResource;
use App\Services\PaymentMethodService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PaymentMethodController extends Controller
{
    public function __construct(private readonly PaymentMethodService $paymentMethods)
    {
    }

    public function index(Request $request): JsonResponse
    {
        return ApiResponse::resource(PaymentMethodResource::collection($this->paymentMethods->list($request->user())));
    }

    public function store(StorePaymentMethodRequest $request): JsonResponse
    {
        $method = $this->paymentMethods->store($request->user(), $request->validated());

        return ApiResponse::resource(new PaymentMethodResource($method), 'Payment method added', 201);
    }

    public function destroy(Request $request, int $paymentMethod): JsonResponse
    {
        $this->paymentMethods->delete($request->user(), $paymentMethod);

        return ApiResponse::success(null, 'Payment method deleted');
    }
}