<?php

namespace App\Services;

use App\Contracts\Repositories\ConversationRepositoryInterface;
use App\Contracts\Repositories\StoreRepositoryInterface;
use App\Exceptions\DomainException;
use App\Models\Conversation;
use App\Models\Message;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class ConversationService
{
    public function __construct(
        private readonly ConversationRepositoryInterface $conversations,
        private readonly StoreRepositoryInterface $stores,
    ) {
    }

    public function list(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return $this->conversations->forUser($user, $perPage);
    }

    public function open(User $user, int $storeId): Conversation
    {
        $this->stores->findOrFail($storeId);

        $existing = $this->conversations->findBetweenUserAndStore($user, $storeId);
        if ($existing) {
            return $existing->load(['store', 'messages' => fn ($q) => $q->latest()->limit(1)]);
        }

        return DB::transaction(function () use ($user, $storeId) {
            /** @var Conversation $conversation */
            $conversation = $this->conversations->create([
                'store_id' => $storeId,
                'title' => 'Store chat',
            ]);

            $conversation->participants()->attach($user->id, ['unread_count' => 0]);

            return $conversation->load('store');
        });
    }

    public function messages(User $user, int $conversationId, int $perPage = 30): LengthAwarePaginator
    {
        $conversation = $this->assertParticipant($user, $conversationId);

        return $conversation->messages()->with('sender')->latest()->paginate($perPage);
    }

    public function send(User $user, int $conversationId, array $data): Message
    {
        $conversation = $this->assertParticipant($user, $conversationId);

        return DB::transaction(function () use ($user, $conversation, $data) {
            $message = $conversation->messages()->create([
                'sender_user_id' => $user->id,
                'body' => $data['body'],
                'attachment_path' => $data['attachment_path'] ?? null,
            ]);

            $conversation->update(['last_message_at' => now()]);

            return $message->load('sender');
        });
    }

    public function markRead(User $user, int $conversationId): void
    {
        $conversation = $this->assertParticipant($user, $conversationId);

        $conversation->messages()
            ->whereNull('read_at')
            ->where('sender_user_id', '!=', $user->id)
            ->update(['read_at' => now()]);

        $conversation->participants()->updateExistingPivot($user->id, ['unread_count' => 0]);
    }

    private function assertParticipant(User $user, int $conversationId): Conversation
    {
        /** @var Conversation $conversation */
        $conversation = $this->conversations->findOrFail($conversationId);

        if (! $conversation->participants()->where('users.id', $user->id)->exists()) {
            throw new DomainException('Conversation not found.', 404, 'conversation_not_found');
        }

        return $conversation;
    }
}