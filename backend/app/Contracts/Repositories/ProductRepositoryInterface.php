<?php

namespace App\Contracts\Repositories;

use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

interface ProductRepositoryInterface extends BaseRepositoryInterface
{
    public function search(array $filters, int $perPage = 15): LengthAwarePaginator;

    public function newArrivals(int $limit = 10): Collection;

    public function forStore(int $storeId, int $perPage = 15): LengthAwarePaginator;

    public function forCategory(int $categoryId, int $perPage = 15): LengthAwarePaginator;
}