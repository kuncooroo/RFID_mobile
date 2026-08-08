<?php

namespace App\Contracts\Repositories;

use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface OrderRepositoryInterface extends BaseRepositoryInterface
{
    public function activeForUser(User $user, int $perPage = 15): LengthAwarePaginator;

    public function historyForUser(User $user, int $perPage = 15): LengthAwarePaginator;
}