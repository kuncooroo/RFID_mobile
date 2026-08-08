<?php

namespace App\Repositories;

use App\Contracts\Repositories\ReviewRepositoryInterface;
use App\Models\Review;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class ReviewRepository extends BaseRepository implements ReviewRepositoryInterface
{
    public function __construct(Review $model)
    {
        parent::__construct($model);
    }

    public function forProduct(int $productId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->query()
            ->with('user')
            ->where('product_id', $productId)
            ->latest()
            ->paginate($perPage);
    }
}