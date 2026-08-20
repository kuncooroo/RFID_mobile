<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class KioskPresence extends Model
{
    protected $fillable = [
        'user_id',
        'rfid_member_id',
        'location_id',
        'device_id',
        'photo_path',
        'status',
        'captured_at',
    ];

    protected function casts(): array
    {
        return [
            'captured_at' => 'datetime',
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

    public function checkIn(): HasOne
    {
        return $this->hasOne(KioskCheckIn::class, 'presence_id');
    }
}
