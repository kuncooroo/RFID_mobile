<?php

namespace App\Repositories;

use App\Contracts\Repositories\NotificationRepositoryInterface;
use App\Models\AppNotification;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class NotificationRepository extends BaseRepository implements NotificationRepositoryInterface
{
    public function __construct(AppNotification $model)
    {
        parent::__construct($model);
    }

    public function forUser(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->query()
            ->where('user_id', $user->id)
            ->latest()
            ->paginate($perPage);
    }

    public function markAllRead(User $user): int
    {
        return $this->query()
            ->where('user_id', $user->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);
    }
}