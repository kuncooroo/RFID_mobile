<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WalletLedger extends Model
{
    protected $fillable = [
        'user_id',
        'check_in_id',
        'delta',
        'balance_after',
        'reason',
    ];

    protected function casts(): array
    {
        return [
            'delta' => 'decimal:2',
            'balance_after' => 'decimal:2',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function checkIn(): BelongsTo
    {
        return $this->belongsTo(KioskCheckIn::class, 'check_in_id');
    }
}
