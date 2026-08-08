<?php

namespace App\Services;

use App\Contracts\Repositories\ProductRepositoryInterface;
use App\Contracts\Repositories\StoreRepositoryInterface;
use App\Models\Store;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class StoreService
{
    public function __construct(
        private readonly StoreRepositoryInterface $stores,
        private readonly ProductRepositoryInterface $products,
    ) {
    }

    public function show(int $id): Store
    {
        /** @var Store $store */
        $store = $this->stores->findOrFail($id);
        $store->setAttribute('product_count', $store->products()->where('is_active', true)->count());

        return $store;
    }

    public function products(int $storeId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->products->forStore($storeId, $perPage);
    }
}