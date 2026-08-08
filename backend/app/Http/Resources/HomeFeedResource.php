<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class HomeFeedResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'promotions' => PromotionResource::collection($this['promotions']),
            'categories' => CategoryResource::collection($this['categories']),
            'new_arrivals' => ProductResource::collection($this['new_arrivals']),
        ];
    }
}