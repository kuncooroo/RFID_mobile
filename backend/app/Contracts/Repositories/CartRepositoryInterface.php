<?php

namespace App\Contracts\Repositories;

use App\Models\Cart;
use App\Models\CartItem;
use App\Models\User;

interface CartRepositoryInterface extends BaseRepositoryInterface
{
    public function getOrCreateForUser(User $user): Cart;

    public function findItem(Cart $cart, int $itemId): ?CartItem;
}