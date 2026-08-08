<?php

namespace App\Http\Requests\Settings;

use Illuminate\Foundation\Http\FormRequest;

class UpdateSettingsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'language_code' => ['sometimes', 'string', 'max:10'],
            'language_label' => ['sometimes', 'string', 'max:100'],
            'push_notifications_enabled' => ['sometimes', 'boolean'],
            'email_notifications_enabled' => ['sometimes', 'boolean'],
            'order_updates_enabled' => ['sometimes', 'boolean'],
            'promo_notifications_enabled' => ['sometimes', 'boolean'],
            'biometric_enabled' => ['sometimes', 'boolean'],
            'two_factor_enabled' => ['sometimes', 'boolean'],
            'currency_code' => ['sometimes', 'string', 'size:3'],
        ];
    }
}