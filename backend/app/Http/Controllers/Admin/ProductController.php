<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Product;
use App\Models\ProductImage;
use App\Models\Store;
use App\Support\AdminActivityLogger;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class ProductController extends Controller
{
    public function index(Request $request): View
    {
        $q = trim((string) $request->query('q', ''));

        $products = Product::query()
            ->with(['category', 'store'])
            ->when($q !== '', function ($query) use ($q) {
                $query->where(function ($inner) use ($q) {
                    $inner->where('name', 'like', "%{$q}%")
                        ->orWhere('brand', 'like', "%{$q}%")
                        ->orWhere('slug', 'like', "%{$q}%");
                });
            })
            ->orderBy('id')
            ->paginate(15)
            ->withQueryString();

        return view('admin.products.index', compact('products', 'q'));
    }

    public function create(): View
    {
        return view('admin.products.create', [
            'stores' => Store::query()->orderBy('name')->get(),
            'categories' => Category::query()->orderBy('name')->get(),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $this->validated($request);

        $product = DB::transaction(function () use ($data, $request) {
            $product = Product::query()->create([
                'store_id' => $data['store_id'],
                'category_id' => $data['category_id'] ?? null,
                'name' => $data['name'],
                'slug' => $data['slug'],
                'brand' => $data['brand'] ?? null,
                'description' => $data['description'] ?? null,
                'price' => $data['price'],
                'discount_price' => $data['discount_price'] ?? null,
                'currency' => $data['currency'],
                'stock' => $data['stock'],
                'is_active' => $data['is_active'],
            ]);

            $this->storePrimaryImage($request, $product);

            return $product;
        });

        AdminActivityLogger::log('product.create', "Created product #{$product->id} {$product->name}", $product);

        return redirect()
            ->route('admin.products.index')
            ->with('success', 'Product created successfully.');
    }

    public function edit(Product $product): View
    {
        $product->load('images');

        return view('admin.products.edit', [
            'product' => $product,
            'stores' => Store::query()->orderBy('name')->get(),
            'categories' => Category::query()->orderBy('name')->get(),
        ]);
    }

    public function update(Request $request, Product $product): RedirectResponse
    {
        $data = $this->validated($request, $product);

        DB::transaction(function () use ($data, $request, $product) {
            $product->update([
                'store_id' => $data['store_id'],
                'category_id' => $data['category_id'] ?? null,
                'name' => $data['name'],
                'slug' => $data['slug'],
                'brand' => $data['brand'] ?? null,
                'description' => $data['description'] ?? null,
                'price' => $data['price'],
                'discount_price' => $data['discount_price'] ?? null,
                'currency' => $data['currency'],
                'stock' => $data['stock'],
                'is_active' => $data['is_active'],
            ]);

            $this->storePrimaryImage($request, $product);
        });

        AdminActivityLogger::log('product.update', "Updated product #{$product->id} {$product->name}", $product);

        return redirect()
            ->route('admin.products.index')
            ->with('success', 'Product updated successfully.');
    }

    public function destroy(Product $product): RedirectResponse
    {
        $label = "#{$product->id} {$product->name}";
        $product->forceDelete();

        AdminActivityLogger::log('product.delete', "Deleted product {$label}");

        return redirect()
            ->route('admin.products.index')
            ->with('success', 'Product deleted successfully.');
    }

    /**
     * @return array<string, mixed>
     */
    private function validated(Request $request, ?Product $product = null): array
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:190'],
            'slug' => [
                'nullable',
                'string',
                'max:190',
                Rule::unique('products', 'slug')->ignore($product?->id),
            ],
            'brand' => ['nullable', 'string', 'max:120'],
            'store_id' => ['required', 'integer', 'exists:stores,id'],
            'category_id' => ['nullable', 'integer', 'exists:categories,id'],
            'price' => ['required', 'numeric', 'min:0'],
            'discount_price' => ['nullable', 'numeric', 'min:0'],
            'currency' => ['required', 'string', 'size:3'],
            'stock' => ['required', 'integer', 'min:0'],
            'description' => ['nullable', 'string'],
            'is_active' => ['sometimes', 'boolean'],
            'image' => ['nullable', 'image', 'max:5120'],
        ]);

        $slug = trim((string) ($data['slug'] ?? ''));
        if ($slug === '') {
            $slug = Str::slug($data['name']);
        }
        if ($slug === '') {
            $slug = 'product-'.Str::lower(Str::random(8));
        }

        $base = $slug;
        $i = 1;
        while (
            Product::query()
                ->where('slug', $slug)
                ->when($product, fn ($q) => $q->where('id', '!=', $product->id))
                ->exists()
        ) {
            $slug = $base.'-'.$i;
            $i++;
        }

        $data['slug'] = $slug;
        $data['currency'] = strtoupper($data['currency']);
        $data['is_active'] = $request->boolean('is_active', true);

        return $data;
    }

    private function storePrimaryImage(Request $request, Product $product): void
    {
        if (! $request->hasFile('image')) {
            return;
        }

        $path = $request->file('image')->store('products', 'public');

        $existing = $product->images()->where('is_primary', true)->first()
            ?? $product->images()->orderBy('sort_order')->first();

        if ($existing) {
            if ($existing->path && Storage::disk('public')->exists($existing->path)) {
                Storage::disk('public')->delete($existing->path);
            }
            $existing->update([
                'path' => $path,
                'is_primary' => true,
            ]);

            return;
        }

        ProductImage::query()->create([
            'product_id' => $product->id,
            'path' => $path,
            'sort_order' => 0,
            'is_primary' => true,
        ]);
    }
}
