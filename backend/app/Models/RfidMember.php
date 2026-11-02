<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class RfidMember extends Model
{
    protected $fillable = [
        'user_id',
        'member_code',
        'rfid_uid',
        'card_number',
        'is_active',
        'balance',
    ];

    protected static function booted(): void
    {
        static::creating(function (RfidMember $card) {
            if ($card->card_number === null || $card->card_number === '') {
                $card->card_number = self::generateCardNumber();
            }
        });
    }

    public static function generateCardNumber(): string
    {
        do {
            $number = '';
            for ($i = 0; $i < 16; $i++) {
                $number .= (string) random_int(0, 9);
            }
        } while (self::query()->where('card_number', $number)->exists());

        return $number;
    }

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'balance' => 'decimal:2',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function verifications(): HasMany
    {
        return $this->hasMany(RfidVerification::class);
    }
}