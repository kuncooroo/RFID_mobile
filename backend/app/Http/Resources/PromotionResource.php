<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Promotion */
class PromotionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'subtitle' => $this->subtitle,
            'image_url' => MediaUrl::make($this->image_path),
            'store_id' => $this->store_id,
            'product_id' => $this->product_id,
            'discount_percent' => $this->discount_percent,
            'deep_link' => $this->deep_link,
        ];
    }
}