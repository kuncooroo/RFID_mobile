<?php

namespace App\Http\Resources;

use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\User */
class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'avatar_url' => MediaUrl::make($this->avatar_path),
            'onboarding_completed_at' => optional($this->onboarding_completed_at)?->toIso8601String(),
            'member' => MemberResource::make($this->whenLoaded('member')),
            'settings' => SettingsResource::make($this->whenLoaded('settings')),
            'created_at' => optional($this->created_at)?->toIso8601String(),
        ];
    }
}