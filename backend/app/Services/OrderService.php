<?php

namespace App\Services;

use App\Contracts\Repositories\OrderRepositoryInterface;
use App\Enums\OrderStatus;
use App\Exceptions\DomainException;
use App\Models\Order;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class OrderService
{
    public function __construct(private readonly OrderRepositoryInterface $orders)
    {
    }

    public function active(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->orders->activeForUser($user, $perPage);
    }

    public function history(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->orders->historyForUser($user, $perPage);
    }

    public function show(User $user, int $orderId): Order
    {
        /** @var Order $order */
        $order = $this->orders->findOrFail($orderId);

        if ($order->user_id !== $user->id) {
            throw new DomainException('Order not found.', 404, 'order_not_found');
        }

        return $order->load(['items', 'address', 'paymentMethod', 'trackingEvents']);
    }

    public function track(User $user, int $orderId): Order
    {
        return $this->show($user, $orderId);
    }

    public function cancel(User $user, int $orderId): Order
    {
        $order = $this->show($user, $orderId);

        if (! $order->status->canCancel()) {
            throw new DomainException('This order cannot be cancelled.', 422, 'cannot_cancel');
        }

        return $this->orders->update($order, ['status' => OrderStatus::Cancelled]);
    }
}