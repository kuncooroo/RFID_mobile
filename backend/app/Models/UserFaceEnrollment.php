<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserFaceEnrollment extends Model
{
    public const POSE_FRONT = 'front';

    public const POSE_RIGHT = 'right';

    public const POSE_LEFT = 'left';

    /** @return list<string> */
    public static function poses(): array
    {
        return [self::POSE_FRONT, self::POSE_RIGHT, self::POSE_LEFT];
    }

    protected $fillable = [
        'user_id',
        'pose',
        'image_path',
        'enrolled_at',
    ];

    protected function casts(): array
    {
        return [
            'enrolled_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
