<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AuthTokenResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'token' => $this['token'],
            'access_token' => $this['token'],
            'refresh_token' => $this['refresh_token'] ?? null,
            'token_type' => 'Bearer',
            'user' => UserResource::make($this['user']),
        ];
    }
}