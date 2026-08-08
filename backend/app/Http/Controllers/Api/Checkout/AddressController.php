<?php

namespace App\Http\Controllers\Api\Checkout;

use App\Http\Controllers\Controller;
use App\Http\Requests\Checkout\StoreAddressRequest;
use App\Http\Resources\AddressResource;
use App\Services\AddressService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AddressController extends Controller
{
    public function __construct(private readonly AddressService $addresses)
    {
    }

    public function index(Request $request): JsonResponse
    {
        return ApiResponse::resource(AddressResource::collection($this->addresses->list($request->user())));
    }

    public function store(StoreAddressRequest $request): JsonResponse
    {
        $address = $this->addresses->store($request->user(), $request->validated());

        return ApiResponse::resource(new AddressResource($address), 'Address created', 201);
    }

    public function update(StoreAddressRequest $request, int $address): JsonResponse
    {
        $updated = $this->addresses->update($request->user(), $address, $request->validated());

        return ApiResponse::resource(new AddressResource($updated), 'Address updated');
    }

    public function destroy(Request $request, int $address): JsonResponse
    {
        $this->addresses->delete($request->user(), $address);

        return ApiResponse::success(null, 'Address deleted');
    }
}