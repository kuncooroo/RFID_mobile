<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserSetting extends Model
{
    protected $fillable = [
        'user_id',
        'language_code',
        'language_label',
        'push_notifications_enabled',
        'email_notifications_enabled',
        'order_updates_enabled',
        'promo_notifications_enabled',
        'biometric_enabled',
        'two_factor_enabled',
        'currency_code',
    ];

    protected function casts(): array
    {
        return [
            'push_notifications_enabled' => 'boolean',
            'email_notifications_enabled' => 'boolean',
            'order_updates_enabled' => 'boolean',
            'promo_notifications_enabled' => 'boolean',
            'biometric_enabled' => 'boolean',
            'two_factor_enabled' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}