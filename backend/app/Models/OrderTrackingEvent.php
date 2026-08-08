<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class OrderTrackingEvent extends Model
{
    protected $fillable = [
        'order_id',
        'title',
        'description',
        'occurred_at',
        'is_completed',
        'sort_order',
    ];

    protected function casts(): array
    {
        return [
            'occurred_at' => 'datetime',
            'is_completed' => 'boolean',
            'sort_order' => 'integer',
        ];
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(Order::class);
    }
}