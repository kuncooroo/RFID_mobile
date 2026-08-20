@extends('admin.layouts.app')

@section('title', 'Add product')
@section('heading', 'Add product')
@section('subheading', 'Create a catalog product for the mobile store.')

@section('content')
<div class="panel">
    <form method="POST" action="{{ route('admin.products.store') }}" class="form-grid" enctype="multipart/form-data">
        @csrf
        @include('admin.products._form')
        <div class="full actions">
            <button class="btn" type="submit">Create product</button>
            <a class="btn secondary" href="{{ route('admin.products.index') }}">Cancel</a>
        </div>
    </form>
</div>
@endsection
