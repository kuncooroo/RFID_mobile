<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Conversation */
class ConversationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $last = $this->whenLoaded('messages') ? $this->messages->first() : null;
        $user = $request->user();
        $unread = 0;
        if ($user) {
            $pivot = $this->participants->firstWhere('id', $user->id)?->pivot;
            $unread = (int) ($pivot?->unread_count ?? 0);
        }

        return [
            'id' => $this->id,
            'title' => $this->title ?? $this->store?->name,
            'avatar_url' => MediaUrl::make($this->store?->logo_path),
            'store_id' => $this->store_id,
            'last_message' => $last?->body,
            'last_message_at' => optional($this->last_message_at)?->toIso8601String(),
            'unread_count' => $unread,
            'store' => StoreResource::make($this->whenLoaded('store')),
        ];
    }
}