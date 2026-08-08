<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Review */
class ReviewResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'product_id' => $this->product_id,
            'rating' => $this->rating,
            'body' => $this->body,
            'user' => UserResource::make($this->whenLoaded('user')),
            'created_at' => optional($this->created_at)?->toIso8601String(),
        ];
    }
}