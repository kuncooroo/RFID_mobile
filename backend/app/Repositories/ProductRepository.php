<?php

namespace App\Repositories;

use App\Contracts\Repositories\ProductRepositoryInterface;
use App\Models\Product;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection;

class ProductRepository extends BaseRepository implements ProductRepositoryInterface
{
    public function __construct(Product $model)
    {
        parent::__construct($model);
    }

    public function search(array $filters, int $perPage = 15): LengthAwarePaginator
    {
        $query = $this->query()
            ->with(['images', 'colors', 'sizes', 'store'])
            ->where('is_active', true);

        if (! empty($filters['q'])) {
            $q = $filters['q'];
            $query->where(function (Builder $builder) use ($q) {
                $builder->where('name', 'like', "%{$q}%")
                    ->orWhere('brand', 'like', "%{$q}%")
                    ->orWhere('description', 'like', "%{$q}%");
            });
        }

        if (! empty($filters['category_id'])) {
            $query->where('category_id', $filters['category_id']);
        }

        if (! empty($filters['store_id'])) {
            $query->where('store_id', $filters['store_id']);
        }

        if (isset($filters['min_price'])) {
            $query->where('price', '>=', $filters['min_price']);
        }

        if (isset($filters['max_price'])) {
            $query->where('price', '<=', $filters['max_price']);
        }

        if (! empty($filters['color_ids']) && is_array($filters['color_ids'])) {
            $query->whereHas('colors', fn (Builder $b) => $b->whereIn('product_colors.id', $filters['color_ids']));
        }

        if (! empty($filters['locations']) && is_array($filters['locations'])) {
            $query->whereHas('store', fn (Builder $b) => $b->whereIn('location', $filters['locations']));
        }

        $sort = $filters['sort'] ?? 'all';
        match ($sort) {
            'price_asc' => $query->orderBy('price'),
            'price_desc' => $query->orderByDesc('price'),
            'rating' => $query->orderByDesc('rating_avg'),
            'newest' => $query->orderByDesc('created_at'),
            default => $query->orderByDesc('id'),
        };

        return $query->paginate($perPage);
    }

    public function newArrivals(int $limit = 10): Collection
    {
        return $this->query()
            ->with(['images', 'colors', 'store'])
            ->where('is_active', true)
            ->latest()
            ->limit($limit)
            ->get();
    }

    public function forStore(int $storeId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->query()
            ->with(['images', 'colors', 'sizes'])
            ->where('store_id', $storeId)
            ->where('is_active', true)
            ->latest()
            ->paginate($perPage);
    }

    public function forCategory(int $categoryId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->query()
            ->with(['images', 'colors', 'store'])
            ->where('category_id', $categoryId)
            ->where('is_active', true)
            ->latest()
            ->paginate($perPage);
    }
}