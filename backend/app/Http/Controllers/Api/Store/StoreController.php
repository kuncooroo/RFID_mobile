<?php

namespace App\Http\Controllers\Api\Store;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProductResource;
use App\Http\Resources\StoreResource;
use App\Services\StoreService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StoreController extends Controller
{
    public function __construct(private readonly StoreService $stores)
    {
    }

    public function show(int $store): JsonResponse
    {
        return ApiResponse::resource(new StoreResource($this->stores->show($store)));
    }

    public function products(Request $request, int $store): JsonResponse
    {
        $paginator = $this->stores->products($store, (int) $request->integer('per_page', 15));

        return ApiResponse::resource(ProductResource::collection($paginator));
    }
}