<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class KioskLocation extends Model
{
    protected $fillable = [
        'code',
        'name',
        'fare_amount',
        'cost_amount',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'fare_amount' => 'decimal:2',
            'cost_amount' => 'decimal:2',
            'is_active' => 'boolean',
        ];
    }

    public function presences(): HasMany
    {
        return $this->hasMany(KioskPresence::class, 'location_id');
    }
}
