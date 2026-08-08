<?php

namespace App\Services;

use App\Contracts\Repositories\AddressRepositoryInterface;
use App\Contracts\Repositories\CartRepositoryInterface;
use App\Contracts\Repositories\OrderRepositoryInterface;
use App\Contracts\Repositories\PaymentMethodRepositoryInterface;
use App\Contracts\Repositories\ProductRepositoryInterface;
use App\Enums\OrderStatus;
use App\Exceptions\DomainException;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class CheckoutService
{
    public function __construct(
        private readonly CartRepositoryInterface $carts,
        private readonly AddressRepositoryInterface $addresses,
        private readonly PaymentMethodRepositoryInterface $paymentMethods,
        private readonly OrderRepositoryInterface $orders,
        private readonly ProductRepositoryInterface $products,
    ) {
    }

    public function checkout(User $user, array $data): Order
    {
        $cart = $this->carts->getOrCreateForUser($user)->load('items');
        $selected = $cart->items->where('is_selected', true);

        if ($selected->isEmpty()) {
            throw new DomainException('No selected cart items to checkout.', 422, 'empty_checkout');
        }

        $address = $this->addresses->findOrFail($data['address_id']);
        if ($address->user_id !== $user->id) {
            throw new DomainException('Invalid address.', 403, 'invalid_address');
        }

        $payment = $this->paymentMethods->findOrFail($data['payment_method_id']);
        if ($payment->user_id !== $user->id) {
            throw new DomainException('Invalid payment method.', 403, 'invalid_payment_method');
        }

        return DB::transaction(function () use ($user, $cart, $selected, $address, $payment) {
            foreach ($selected as $item) {
                /** @var Product $product */
                $product = Product::query()->lockForUpdate()->findOrFail($item->product_id);
                if ($product->stock < $item->quantity) {
                    throw new DomainException("Insufficient stock for {$product->name}.", 422, 'insufficient_stock');
                }
            }

            $subtotal = $selected->sum(fn ($i) => (float) $i->unit_price * $i->quantity);
            // Shipping/discount are server-controlled — never trust the client.
            $shipping = $subtotal >= 100 ? 0.0 : 5.0;
            $discount = 0.0;
            $total = max(0, $subtotal + $shipping - $discount);

            /** @var Order $order */
            $order = $this->orders->create([
                'user_id' => $user->id,
                'order_number' => 'ORD-'.Str::upper(Str::random(10)),
                'status' => OrderStatus::Pending,
                'subtotal' => $subtotal,
                'shipping_fee' => $shipping,
                'discount' => $discount,
                'total' => $total,
                'currency' => $cart->currency,
                'address_id' => $address->id,
                'payment_method_id' => $payment->id,
                'placed_at' => now(),
            ]);

            foreach ($selected as $item) {
                $order->items()->create([
                    'product_id' => $item->product_id,
                    'name' => $item->name,
                    'unit_price' => $item->unit_price,
                    'quantity' => $item->quantity,
                    'image_path' => $item->image_path,
                    'variant_label' => trim(implode(' / ', array_filter([$item->color_name, $item->size]))),
                ]);

                $product = Product::query()->lockForUpdate()->findOrFail($item->product_id);
                $this->products->update($product, [
                    'stock' => max(0, $product->stock - $item->quantity),
                ]);
            }

            $order->trackingEvents()->createMany([
                [
                    'title' => 'Order Placed',
                    'description' => 'We have received your order.',
                    'occurred_at' => now(),
                    'is_completed' => true,
                    'sort_order' => 1,
                ],
                [
                    'title' => 'Awaiting Payment',
                    'description' => 'Waiting for payment confirmation.',
                    'occurred_at' => now(),
                    'is_completed' => false,
                    'sort_order' => 2,
                ],
                [
                    'title' => 'Processing',
                    'description' => 'Seller is preparing your package.',
                    'occurred_at' => now()->addHour(),
                    'is_completed' => false,
                    'sort_order' => 3,
                ],
            ]);

            $cart->items()->whereIn('id', $selected->pluck('id'))->delete();
            $user->member?->increment('orders_count');

            return $order->load(['items', 'address', 'paymentMethod', 'trackingEvents']);
        });
    }
}