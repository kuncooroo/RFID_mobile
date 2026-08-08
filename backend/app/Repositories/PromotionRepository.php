<?php

namespace App\Repositories;

use App\Contracts\Repositories\PromotionRepositoryInterface;
use App\Models\Promotion;
use Illuminate\Database\Eloquent\Collection;

class PromotionRepository extends BaseRepository implements PromotionRepositoryInterface
{
    public function __construct(Promotion $model)
    {
        parent::__construct($model);
    }

    public function activePromotions(): Collection
    {
        return $this->query()->active()->orderBy('sort_order')->get();
    }
}