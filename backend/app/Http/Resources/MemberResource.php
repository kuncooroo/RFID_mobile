<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Member */
class MemberResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'display_name' => $this->display_name,
            'membership_tier' => $this->membership_tier,
            'points' => $this->points,
            'orders_count' => $this->orders_count,
            'favorites_count' => $this->favorites_count,
            'followers_count' => $this->followers_count,
        ];
    }
}