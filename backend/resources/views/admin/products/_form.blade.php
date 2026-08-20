@php
    /** @var \App\Models\Product|null $product */
    $product = $product ?? null;
@endphp

<label>
    Name
    <input type="text" name="name" value="{{ old('name', $product?->name) }}" required>
</label>
<label>
    Slug
    <input type="text" name="slug" value="{{ old('slug', $product?->slug) }}" placeholder="Auto from name if empty">
</label>
<label>
    Brand
    <input type="text" name="brand" value="{{ old('brand', $product?->brand) }}">
</label>
<label>
    Store
    <select name="store_id" required>
        <option value="">Select store</option>
        @foreach($stores as $store)
            <option value="{{ $store->id }}" @selected((string) old('store_id', $product?->store_id) === (string) $store->id)>
                {{ $store->name }}
            </option>
        @endforeach
    </select>
</label>
<label>
    Category
    <select name="category_id">
        <option value="">— None —</option>
        @foreach($categories as $category)
            <option value="{{ $category->id }}" @selected((string) old('category_id', $product?->category_id) === (string) $category->id)>
                {{ $category->name }}
            </option>
        @endforeach
    </select>
</label>
<label>
    Price
    <input type="number" step="0.01" min="0" name="price" value="{{ old('price', $product?->price) }}" required>
</label>
<label>
    Discount price
    <input type="number" step="0.01" min="0" name="discount_price" value="{{ old('discount_price', $product?->discount_price) }}">
</label>
<label>
    Currency
    <input type="text" name="currency" maxlength="3" value="{{ old('currency', $product?->currency ?? 'USD') }}" required>
</label>
<label>
    Stock
    <input type="number" min="0" name="stock" value="{{ old('stock', $product?->stock ?? 0) }}" required>
</label>
<label>
    Status
    <select name="is_active">
        <option value="1" @selected((string) old('is_active', $product?->is_active ?? true) === '1')>Active</option>
        <option value="0" @selected((string) old('is_active', $product?->is_active ?? true) === '0')>Inactive</option>
    </select>
</label>
<label class="full">
    Description
    <textarea name="description" rows="4">{{ old('description', $product?->description) }}</textarea>
</label>
<label class="full">
    Primary image
    <input type="file" name="image" accept="image/*">
    @if($product?->primaryImage())
        <div class="muted" style="margin-top:8px;">Current: {{ $product->primaryImage()->path }}</div>
    @endif
</label>
