<?php

namespace App\Contracts\Repositories;

use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

interface PaymentMethodRepositoryInterface extends BaseRepositoryInterface
{
    public function forUser(User $user): Collection;

    public function clearDefault(User $user): void;
}