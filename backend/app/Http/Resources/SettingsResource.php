<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\UserSetting */
class SettingsResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'language_code' => $this->language_code,
            'language_label' => $this->language_label,
            'push_notifications_enabled' => $this->push_notifications_enabled,
            'email_notifications_enabled' => $this->email_notifications_enabled,
            'order_updates_enabled' => $this->order_updates_enabled,
            'promo_notifications_enabled' => $this->promo_notifications_enabled,
            'biometric_enabled' => $this->biometric_enabled,
            'two_factor_enabled' => $this->two_factor_enabled,
            'currency_code' => $this->currency_code,
        ];
    }
}