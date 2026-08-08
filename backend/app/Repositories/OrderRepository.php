<?php

namespace App\Repositories;

use App\Contracts\Repositories\OrderRepositoryInterface;
use App\Enums\OrderStatus;
use App\Models\Order;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class OrderRepository extends BaseRepository implements OrderRepositoryInterface
{
    public function __construct(Order $model)
    {
        parent::__construct($model);
    }

    public function activeForUser(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->query()
            ->with(['items', 'trackingEvents'])
            ->where('user_id', $user->id)
            ->whereIn('status', [
                OrderStatus::Pending->value,
                OrderStatus::Paid->value,
                OrderStatus::Processing->value,
                OrderStatus::Shipped->value,
            ])
            ->latest('placed_at')
            ->paginate($perPage);
    }

    public function historyForUser(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->query()
            ->with(['items'])
            ->where('user_id', $user->id)
            ->whereIn('status', [
                OrderStatus::Delivered->value,
                OrderStatus::Cancelled->value,
                OrderStatus::Refunded->value,
            ])
            ->latest('placed_at')
            ->paginate($perPage);
    }
}