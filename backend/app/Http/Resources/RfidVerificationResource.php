<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\RfidVerification */
class RfidVerificationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'member_id' => $this->rfidMember?->member_code,
            'gate_opened' => $this->gate_opened,
            'status' => $this->status,
            'message' => $this->message,
            'verified_at' => optional($this->verified_at)?->toIso8601String(),
        ];
    }
}