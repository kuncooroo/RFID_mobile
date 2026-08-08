<?php

namespace App\Http\Requests\Search;

use Illuminate\Foundation\Http\FormRequest;

class ProductSearchRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'q' => ['nullable', 'string', 'max:200'],
            'category_id' => ['nullable', 'integer', 'exists:categories,id'],
            'store_id' => ['nullable', 'integer', 'exists:stores,id'],
            'min_price' => ['nullable', 'numeric', 'min:0'],
            'max_price' => ['nullable', 'numeric', 'min:0'],
            'color_ids' => ['nullable', 'array'],
            'color_ids.*' => ['integer', 'exists:product_colors,id'],
            'locations' => ['nullable', 'array'],
            'locations.*' => ['string', 'max:120'],
            'sort' => ['nullable', 'in:all,price_asc,price_desc,rating,newest'],
            'per_page' => ['nullable', 'integer', 'min:1', 'max:50'],
        ];
    }
}