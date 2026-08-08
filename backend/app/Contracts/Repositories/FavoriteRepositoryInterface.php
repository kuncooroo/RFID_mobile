<?php

namespace App\Contracts\Repositories;

use App\Models\Favorite;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface FavoriteRepositoryInterface extends BaseRepositoryInterface
{
    public function forUser(User $user, int $perPage = 15): LengthAwarePaginator;

    public function findForUserProduct(User $user, int $productId): ?Favorite;

    public function clearForUser(User $user): int;
}