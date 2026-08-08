<?php

namespace App\Contracts\Repositories;

use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface NotificationRepositoryInterface extends BaseRepositoryInterface
{
    public function forUser(User $user, int $perPage = 15): LengthAwarePaginator;

    public function markAllRead(User $user): int;
}