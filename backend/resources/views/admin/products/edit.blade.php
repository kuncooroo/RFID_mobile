@extends('admin.layouts.app')

@section('title', 'Edit product')
@section('heading', 'Edit product')
@section('subheading', $product->name)

@section('content')
<div class="panel">
    <form method="POST" action="{{ route('admin.products.update', $product) }}" class="form-grid" enctype="multipart/form-data">
        @csrf
        @method('PUT')
        @include('admin.products._form')
        <div class="full actions">
            <button class="btn" type="submit">Save changes</button>
            <a class="btn secondary" href="{{ route('admin.products.index') }}">Cancel</a>
        </div>
    </form>
</div>
@endsection
