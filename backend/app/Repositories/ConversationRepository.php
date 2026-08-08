<?php

namespace App\Repositories;

use App\Contracts\Repositories\ConversationRepositoryInterface;
use App\Models\Conversation;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class ConversationRepository extends BaseRepository implements ConversationRepositoryInterface
{
    public function __construct(Conversation $model)
    {
        parent::__construct($model);
    }

    public function forUser(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->query()
            ->with([
                'store',
                'participants',
                'messages' => fn ($q) => $q->latest()->limit(1),
            ])
            ->whereHas('participants', fn ($q) => $q->where('users.id', $user->id))
            ->orderByDesc('last_message_at')
            ->paginate($perPage);
    }

    public function findBetweenUserAndStore(User $user, int $storeId): ?Conversation
    {
        return $this->query()
            ->where('store_id', $storeId)
            ->whereHas('participants', fn ($q) => $q->where('users.id', $user->id))
            ->first();
    }
}