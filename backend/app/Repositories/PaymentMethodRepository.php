<?php

namespace App\Repositories;

use App\Contracts\Repositories\PaymentMethodRepositoryInterface;
use App\Models\PaymentMethod;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

class PaymentMethodRepository extends BaseRepository implements PaymentMethodRepositoryInterface
{
    public function __construct(PaymentMethod $model)
    {
        parent::__construct($model);
    }

    public function forUser(User $user): Collection
    {
        return $this->query()->where('user_id', $user->id)->latest()->get();
    }

    public function clearDefault(User $user): void
    {
        $this->query()->where('user_id', $user->id)->update(['is_default' => false]);
    }
}