<?php

namespace App\Http\Controllers\Api\Cart;

use App\Http\Controllers\Controller;
use App\Http\Requests\Cart\SelectAllCartRequest;
use App\Http\Requests\Cart\StoreCartItemRequest;
use App\Http\Requests\Cart\UpdateCartItemRequest;
use App\Http\Resources\CartResource;
use App\Services\CartService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CartController extends Controller
{
    public function __construct(private readonly CartService $carts)
    {
    }

    public function show(Request $request): JsonResponse
    {
        return ApiResponse::resource(new CartResource($this->carts->get($request->user())));
    }

    public function storeItem(StoreCartItemRequest $request): JsonResponse
    {
        $cart = $this->carts->addItem($request->user(), $request->validated());

        return ApiResponse::resource(new CartResource($cart), 'Item added to cart', 201);
    }

    public function updateItem(UpdateCartItemRequest $request, int $cartItem): JsonResponse
    {
        $cart = $this->carts->updateItem($request->user(), $cartItem, $request->validated());

        return ApiResponse::resource(new CartResource($cart), 'Cart updated');
    }

    public function destroyItem(Request $request, int $cartItem): JsonResponse
    {
        $cart = $this->carts->removeItem($request->user(), $cartItem);

        return ApiResponse::resource(new CartResource($cart), 'Item removed');
    }

    public function selectAll(SelectAllCartRequest $request): JsonResponse
    {
        $cart = $this->carts->selectAll($request->user(), (bool) $request->validated('selected'));

        return ApiResponse::resource(new CartResource($cart), 'Selection updated');
    }
}