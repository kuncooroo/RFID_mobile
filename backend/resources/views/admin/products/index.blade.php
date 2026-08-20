@extends('admin.layouts.app')

@section('title', 'Products')
@section('heading', 'Products')
@section('subheading', 'Store catalog shown in the Kutuku mobile app.')

@section('content')
<div class="toolbar">
    <form method="GET" action="{{ route('admin.products.index') }}">
        <input class="search" type="search" name="q" value="{{ $q }}" placeholder="Search name, brand, slug…">
        <button class="btn secondary" type="submit">Search</button>
    </form>
    <a class="btn" href="{{ route('admin.products.create') }}">Add product</a>
</div>

<div class="panel">
    <div class="panel-header">
        <h2>Catalog</h2>
        <span class="muted">{{ $products->total() }} products</span>
    </div>
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>No</th>
                <th>Name</th>
                <th>Category</th>
                <th>Store</th>
                <th>Price</th>
                <th>Stock</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            @forelse($products as $product)
                <tr>
                    <td>{{ ($products->firstItem() ?? 0) + $loop->index }}</td>
                    <td>
                        <strong>{{ $product->name }}</strong>
                        <div class="muted">{{ $product->brand ?? '—' }}</div>
                    </td>
                    <td>{{ $product->category?->name ?? '—' }}</td>
                    <td>{{ $product->store?->name ?? '—' }}</td>
                    <td>
                        {{ strtoupper($product->currency ?? 'USD') }}
                        {{ number_format((float) $product->price, 2) }}
                    </td>
                    <td>{{ $product->stock }}</td>
                    <td>
                        @if($product->is_active)
                            <span class="badge ok">Active</span>
                        @else
                            <span class="badge warn">Inactive</span>
                        @endif
                    </td>
                    <td class="actions">
                        <a class="btn secondary sm" href="{{ route('admin.products.edit', $product) }}">Edit</a>
                        <form method="POST" action="{{ route('admin.products.destroy', $product) }}" onsubmit="return confirm('Delete this product?')">
                            @csrf
                            @method('DELETE')
                            <button class="btn danger sm" type="submit">Delete</button>
                        </form>
                    </td>
                </tr>
            @empty
                <tr><td colspan="8">No products found.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
    <div class="pagination">{{ $products->links('admin.partials.pagination') }}</div>
</div>
@endsection
