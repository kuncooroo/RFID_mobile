<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Product */
class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $images = $this->whenLoaded('images', function () {
            return $this->images->pluck('path')->map(fn ($p) => MediaUrl::make($p))->values();
        }, []);

        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'brand' => $this->brand,
            'description' => $this->description,
            'price' => (float) $this->price,
            'discount_price' => $this->discount_price !== null ? (float) $this->discount_price : null,
            'currency' => $this->currency,
            'stock' => $this->stock,
            'rating' => (float) $this->rating_avg,
            'review_count' => $this->reviews_count,
            'image_url' => MediaUrl::make($this->primaryImage()?->path),
            'images' => $images,
            'category_id' => $this->category_id,
            'store_id' => $this->store_id,
            'store' => StoreResource::make($this->whenLoaded('store')),
            'category' => CategoryResource::make($this->whenLoaded('category')),
            'colors' => ProductColorResource::collection($this->whenLoaded('colors')),
            'sizes' => $this->whenLoaded('sizes', fn () => $this->sizes->pluck('label')->values()),
            'is_favorite' => (bool) ($this->is_favorite ?? false),
        ];
    }
}