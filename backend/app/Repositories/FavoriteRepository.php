<?php

namespace App\Repositories;

use App\Contracts\Repositories\FavoriteRepositoryInterface;
use App\Models\Favorite;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class FavoriteRepository extends BaseRepository implements FavoriteRepositoryInterface
{
    public function __construct(Favorite $model)
    {
        parent::__construct($model);
    }

    public function forUser(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->query()
            ->with(['product.images', 'product.store', 'product.colors'])
            ->where('user_id', $user->id)
            ->latest()
            ->paginate($perPage);
    }

    public function findForUserProduct(User $user, int $productId): ?Favorite
    {
        return $this->query()
            ->where('user_id', $user->id)
            ->where('product_id', $productId)
            ->first();
    }

    public function clearForUser(User $user): int
    {
        return $this->query()->where('user_id', $user->id)->delete();
    }
}