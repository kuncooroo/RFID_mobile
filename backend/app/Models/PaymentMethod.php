<?php

namespace App\Models;

use App\Enums\PaymentMethodType;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PaymentMethod extends Model
{
    protected $fillable = [
        'user_id',
        'type',
        'brand',
        'last4',
        'holder_name',
        'expiry_month',
        'expiry_year',
        'provider_token',
        'is_default',
    ];

    protected $hidden = [
        'provider_token',
    ];

    protected function casts(): array
    {
        return [
            'type' => PaymentMethodType::class,
            'expiry_month' => 'integer',
            'expiry_year' => 'integer',
            'is_default' => 'boolean',
            'provider_token' => 'encrypted',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}