<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Store extends Model
{
    protected $fillable = [
        'name',
        'slug',
        'logo_path',
        'banner_path',
        'description',
        'is_verified',
        'rating_avg',
        'location',
    ];

    protected function casts(): array
    {
        return [
            'is_verified' => 'boolean',
            'rating_avg' => 'float',
        ];
    }

    public function products(): HasMany
    {
        return $this->hasMany(Product::class);
    }

    public function conversations(): HasMany
    {
        return $this->hasMany(Conversation::class);
    }
}