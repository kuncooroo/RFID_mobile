<?php

namespace App\Services;

use App\Contracts\Repositories\FavoriteRepositoryInterface;
use App\Contracts\Repositories\ProductRepositoryInterface;
use App\Exceptions\DomainException;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class FavoriteService
{
    public function __construct(
        private readonly FavoriteRepositoryInterface $favorites,
        private readonly ProductRepositoryInterface $products,
    ) {
    }

    public function list(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->favorites->forUser($user, $perPage);
    }

    public function add(User $user, int $productId)
    {
        $this->products->findOrFail($productId);

        if ($this->favorites->findForUserProduct($user, $productId)) {
            throw new DomainException('Product is already in favorites.', 422, 'already_favorited');
        }

        return DB::transaction(function () use ($user, $productId) {
            $favorite = $this->favorites->create([
                'user_id' => $user->id,
                'product_id' => $productId,
            ]);

            $user->member?->increment('favorites_count');

            return $favorite->load(['product.images', 'product.store']);
        });
    }

    public function remove(User $user, int $productId): void
    {
        $favorite = $this->favorites->findForUserProduct($user, $productId);

        if (! $favorite) {
            throw new DomainException('Favorite not found.', 404, 'favorite_not_found');
        }

        DB::transaction(function () use ($user, $favorite) {
            $this->favorites->delete($favorite);
            if ($user->member && $user->member->favorites_count > 0) {
                $user->member->decrement('favorites_count');
            }
        });
    }

    public function clear(User $user): void
    {
        DB::transaction(function () use ($user) {
            $this->favorites->clearForUser($user);
            $user->member?->update(['favorites_count' => 0]);
        });
    }
}