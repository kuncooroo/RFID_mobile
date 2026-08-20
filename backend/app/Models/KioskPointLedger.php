<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class KioskPointLedger extends Model
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
            'delta' => 'integer',
            'balance_after' => 'integer',
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
