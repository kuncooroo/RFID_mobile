<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\OrderItem */
class OrderItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'product_id' => $this->product_id,
            'name' => $this->name,
            'unit_price' => (float) $this->unit_price,
            'quantity' => $this->quantity,
            'image_url' => MediaUrl::make($this->image_path),
            'variant_label' => $this->variant_label,
        ];
    }
}