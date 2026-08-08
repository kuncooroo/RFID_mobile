<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class ProductColor extends Model
{
    protected $fillable = ['name', 'hex'];

    public function products(): BelongsToMany
    {
        return $this->belongsToMany(Product::class, 'product_color_product');
    }
}