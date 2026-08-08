<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\CartItem */
class CartItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'product_id' => $this->product_id,
            'name' => $this->name,
            'unit_price' => (float) $this->unit_price,
            'quantity' => $this->quantity,
            'line_total' => (float) $this->line_total,
            'image_url' => MediaUrl::make($this->image_path),
            'brand' => $this->brand,
            'color_name' => $this->color_name,
            'size' => $this->size,
            'is_selected' => $this->is_selected,
            'product' => ProductResource::make($this->whenLoaded('product')),
        ];
    }
}