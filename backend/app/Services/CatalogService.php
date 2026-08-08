<?php

namespace App\Services;

use App\Contracts\Repositories\CategoryRepositoryInterface;
use App\Contracts\Repositories\ProductRepositoryInterface;
use App\Models\Category;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

class CatalogService
{
    public function __construct(
        private readonly CategoryRepositoryInterface $categories,
        private readonly ProductRepositoryInterface $products,
    ) {
    }

    public function categories(): Collection
    {
        return $this->categories->activeRoots();
    }

    public function category(int $id): Category
    {
        /** @var Category $category */
        $category = $this->categories->findOrFail($id);

        return $category->load('children');
    }

    public function categoryProducts(int $categoryId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->products->forCategory($categoryId, $perPage);
    }
}