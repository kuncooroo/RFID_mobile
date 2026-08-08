<?php

namespace App\Repositories;

use App\Contracts\Repositories\AddressRepositoryInterface;
use App\Models\Address;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

class AddressRepository extends BaseRepository implements AddressRepositoryInterface
{
    public function __construct(Address $model)
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