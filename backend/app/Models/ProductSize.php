<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class ProductSize extends Model
{
    protected $fillable = ['label'];

    public function products(): BelongsToMany
    {
        return $this->belongsToMany(Product::class, 'product_product_size');
    }
}