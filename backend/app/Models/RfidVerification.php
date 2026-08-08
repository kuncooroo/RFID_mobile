<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RfidVerification extends Model
{
    protected $fillable = [
        'rfid_member_id',
        'user_id',
        'captured_image_path',
        'gate_opened',
        'status',
        'message',
        'verified_at',
    ];

    protected function casts(): array
    {
        return [
            'gate_opened' => 'boolean',
            'verified_at' => 'datetime',
        ];
    }

    public function rfidMember(): BelongsTo
    {
        return $this->belongsTo(RfidMember::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}