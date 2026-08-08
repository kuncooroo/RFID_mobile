<?php

namespace App\Services;

use App\Contracts\Repositories\CartRepositoryInterface;
use App\Contracts\Repositories\ProductRepositoryInterface;
use App\Exceptions\DomainException;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Product;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class CartService
{
    public function __construct(
        private readonly CartRepositoryInterface $carts,
        private readonly ProductRepositoryInterface $products,
    ) {
    }

    public function get(User $user): Cart
    {
        $cart = $this->carts->getOrCreateForUser($user);

        return $cart->load(['items.product.images']);
    }

    public function addItem(User $user, array $data): Cart
    {
        /** @var Product $product */
        $product = $this->products->findOrFail($data['product_id']);
        $product->load('images');

        if ($product->stock < ($data['quantity'] ?? 1)) {
            throw new DomainException('Insufficient stock.', 422, 'insufficient_stock');
        }

        return DB::transaction(function () use ($user, $product, $data) {
            $cart = $this->carts->getOrCreateForUser($user);

            $existing = $cart->items()
                ->where('product_id', $product->id)
                ->where('color_name', $data['color_name'] ?? null)
                ->where('size', $data['size'] ?? null)
                ->first();

            if ($existing) {
                $existing->update([
                    'quantity' => $existing->quantity + ($data['quantity'] ?? 1),
                    'unit_price' => $product->discount_price ?? $product->price,
                ]);
            } else {
                $cart->items()->create([
                    'product_id' => $product->id,
                    'name' => $product->name,
                    'unit_price' => $product->discount_price ?? $product->price,
                    'quantity' => $data['quantity'] ?? 1,
                    'image_path' => $product->primaryImage()?->path,
                    'brand' => $product->brand,
                    'color_name' => $data['color_name'] ?? null,
                    'size' => $data['size'] ?? null,
                    'is_selected' => true,
                ]);
            }

            return $cart->fresh()->load(['items.product.images']);
        });
    }

    public function updateItem(User $user, int $itemId, array $data): Cart
    {
        $cart = $this->carts->getOrCreateForUser($user);
        $item = $this->carts->findItem($cart, $itemId);

        if (! $item) {
            throw new DomainException('Cart item not found.', 404, 'cart_item_not_found');
        }

        $payload = [];
        if (array_key_exists('quantity', $data)) {
            $payload['quantity'] = $data['quantity'];
        }
        if (array_key_exists('is_selected', $data)) {
            $payload['is_selected'] = $data['is_selected'];
        }

        $item->update($payload);

        return $cart->fresh()->load(['items.product.images']);
    }

    public function removeItem(User $user, int $itemId): Cart
    {
        $cart = $this->carts->getOrCreateForUser($user);
        $item = $this->carts->findItem($cart, $itemId);

        if (! $item) {
            throw new DomainException('Cart item not found.', 404, 'cart_item_not_found');
        }

        $item->delete();

        return $cart->fresh()->load(['items.product.images']);
    }

    public function selectAll(User $user, bool $selected = true): Cart
    {
        $cart = $this->carts->getOrCreateForUser($user);
        $cart->items()->update(['is_selected' => $selected]);

        return $cart->fresh()->load(['items.product.images']);
    }
}