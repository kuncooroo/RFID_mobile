<?php

namespace App\Services;

use App\Contracts\Repositories\FavoriteRepositoryInterface;
use App\Contracts\Repositories\ProductRepositoryInterface;
use App\Contracts\Repositories\ReviewRepositoryInterface;
use App\Models\Product;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class ProductService
{
    public function __construct(
        private readonly ProductRepositoryInterface $products,
        private readonly FavoriteRepositoryInterface $favorites,
        private readonly ReviewRepositoryInterface $reviews,
    ) {
    }

    public function search(array $filters, int $perPage = 15): LengthAwarePaginator
    {
        return $this->products->search($filters, $perPage);
    }

    public function show(int $id, ?User $user = null): Product
    {
        /** @var Product $product */
        $product = $this->products->findOrFail($id);
        $product->load(['images', 'colors', 'sizes', 'store', 'category']);

        if ($user) {
            $product->setAttribute(
                'is_favorite',
                $this->favorites->findForUserProduct($user, $product->id) !== null
            );
        }

        return $product;
    }

    public function reviews(int $productId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->reviews->forProduct($productId, $perPage);
    }

    public function addReview(User $user, array $data)
    {
        $review = $this->reviews->create([
            'user_id' => $user->id,
            'product_id' => $data['product_id'],
            'rating' => $data['rating'],
            'body' => $data['body'] ?? null,
        ]);

        $this->recalculateProductRating((int) $data['product_id']);

        return $review->load('user');
    }

    private function recalculateProductRating(int $productId): void
    {
        /** @var Product $product */
        $product = $this->products->findOrFail($productId);
        $avg = $product->reviews()->avg('rating') ?? 0;
        $count = $product->reviews()->count();
        $this->products->update($product, [
            'rating_avg' => round((float) $avg, 2),
            'reviews_count' => $count,
        ]);
    }
}