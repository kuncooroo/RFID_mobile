<?php

namespace App\Services;

use App\Contracts\Repositories\CategoryRepositoryInterface;
use App\Contracts\Repositories\ProductRepositoryInterface;
use App\Contracts\Repositories\PromotionRepositoryInterface;

class HomeFeedService
{
    public function __construct(
        private readonly PromotionRepositoryInterface $promotions,
        private readonly CategoryRepositoryInterface $categories,
        private readonly ProductRepositoryInterface $products,
    ) {
    }

    /** @return array{promotions:mixed,categories:mixed,new_arrivals:mixed} */
    public function feed(): array
    {
        return [
            'promotions' => $this->promotions->activePromotions(),
            'categories' => $this->categories->activeRoots(),
            'new_arrivals' => $this->products->newArrivals(12),
        ];
    }
}