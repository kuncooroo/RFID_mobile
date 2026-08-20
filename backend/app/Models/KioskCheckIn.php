<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class KioskCheckIn extends Model
{
    protected $fillable = [
        'user_id',
        'rfid_member_id',
        'location_id',
        'presence_id',
        'status',
        'points_awarded',
        'checked_in_at',
    ];

    protected function casts(): array
    {
        return [
            'points_awarded' => 'integer',
            'checked_in_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function rfidMember(): BelongsTo
    {
        return $this->belongsTo(RfidMember::class);
    }

    public function location(): BelongsTo
    {
        return $this->belongsTo(KioskLocation::class, 'location_id');
    }

    public function presence(): BelongsTo
    {
        return $this->belongsTo(KioskPresence::class, 'presence_id');
    }
}
