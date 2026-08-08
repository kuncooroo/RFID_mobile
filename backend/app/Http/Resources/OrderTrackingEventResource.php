<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\OrderTrackingEvent */
class OrderTrackingEventResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'occurred_at' => optional($this->occurred_at)?->toIso8601String(),
            'is_completed' => $this->is_completed,
            'sort_order' => $this->sort_order,
        ];
    }
}