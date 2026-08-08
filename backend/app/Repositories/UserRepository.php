<?php

namespace App\Repositories;

use App\Contracts\Repositories\UserRepositoryInterface;
use App\Models\User;

class UserRepository extends BaseRepository implements UserRepositoryInterface
{
    public function __construct(User $model)
    {
        parent::__construct($model);
    }

    public function findByEmail(string $email): ?User
    {
        return $this->query()->where('email', $email)->first();
    }

    public function findByPhone(string $phone): ?User
    {
        return $this->query()->where('phone', $phone)->first();
    }

    public function findByIdentifier(string $identifier): ?User
    {
        return $this->query()
            ->where(function ($q) use ($identifier) {
                $q->where('email', $identifier)->orWhere('phone', $identifier);
            })
            ->first();
    }
}