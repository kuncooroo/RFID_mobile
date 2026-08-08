<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Store */
class StoreResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'logo_url' => MediaUrl::make($this->logo_path),
            'banner_url' => MediaUrl::make($this->banner_path),
            'description' => $this->description,
            'is_verified' => $this->is_verified,
            'rating' => (float) $this->rating_avg,
            'location' => $this->location,
            'product_count' => $this->when(isset($this->product_count), $this->product_count),
        ];
    }
}