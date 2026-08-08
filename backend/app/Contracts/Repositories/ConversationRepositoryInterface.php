<?php

namespace App\Contracts\Repositories;

use App\Models\Conversation;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface ConversationRepositoryInterface extends BaseRepositoryInterface
{
    public function forUser(User $user, int $perPage = 15): LengthAwarePaginator;

    public function findBetweenUserAndStore(User $user, int $storeId): ?Conversation;
}