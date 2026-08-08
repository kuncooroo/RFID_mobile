<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Cart */
class CartResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $items = $this->whenLoaded('items') ? $this->items : collect();

        return [
            'id' => $this->id,
            'currency' => $this->currency,
            'items' => CartItemResource::collection($this->whenLoaded('items')),
            'item_count' => $items->sum('quantity'),
            'subtotal' => (float) $items->where('is_selected', true)->sum(fn ($i) => $i->line_total),
        ];
    }
}