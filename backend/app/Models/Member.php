<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Member extends Model
{
    protected $fillable = [
        'user_id',
        'display_name',
        'membership_tier',
        'points',
        'balance',
        'discount_credit',
        'orders_count',
        'favorites_count',
        'followers_count',
    ];

    protected function casts(): array
    {
        return [
            'points' => 'integer',
            'balance' => 'decimal:2',
            'discount_credit' => 'decimal:2',
            'orders_count' => 'integer',
            'favorites_count' => 'integer',
            'followers_count' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}