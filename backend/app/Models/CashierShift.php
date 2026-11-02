<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class CashierShift extends Model
{
    protected $fillable = [
        'admin_id',
        'status',
        'opening_float',
        'opened_at',
        'closed_at',
        'cash_counted',
        'note',
    ];

    protected function casts(): array
    {
        return [
            'opening_float' => 'decimal:2',
            'cash_counted' => 'decimal:2',
            'opened_at' => 'datetime',
            'closed_at' => 'datetime',
        ];
    }

    public function admin(): BelongsTo
    {
        return $this->belongsTo(Admin::class);
    }

    public function ledgers(): HasMany
    {
        return $this->hasMany(WalletLedger::class, 'shift_id');
    }

    public function isOpen(): bool
    {
        return $this->status === 'open';
    }
}
