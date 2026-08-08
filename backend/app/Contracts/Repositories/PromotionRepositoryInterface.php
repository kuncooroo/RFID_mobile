<?php

namespace App\Contracts\Repositories;

use Illuminate\Database\Eloquent\Collection;

interface PromotionRepositoryInterface extends BaseRepositoryInterface
{
    public function activePromotions(): Collection;
}