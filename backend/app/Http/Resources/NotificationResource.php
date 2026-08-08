<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\AppNotification */
class NotificationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'body' => $this->body,
            'type' => $this->type?->value ?? $this->type,
            'image_url' => MediaUrl::make($this->image_path),
            'is_read' => $this->is_read,
            'reference_type' => $this->reference_type,
            'reference_id' => $this->reference_id,
            'created_at' => optional($this->created_at)?->toIso8601String(),
        ];
    }
}