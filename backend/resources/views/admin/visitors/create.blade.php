@extends('admin.layouts.app')

@section('title', 'Add visitor')
@section('heading', 'Add visitor')
@section('subheading', 'Create a mobile-app visitor account.')

@section('content')
<div class="panel">
    <form method="POST" action="{{ route('admin.visitors.store') }}" class="form-grid">
        @csrf
        <label>
            Name
            <input type="text" name="name" value="{{ old('name') }}" required>
        </label>
        <label>
            Email
            <input type="email" name="email" value="{{ old('email') }}">
        </label>
        <label>
            Phone
            <input type="text" name="phone" value="{{ old('phone') }}">
        </label>
        <label>
            Password
            <input type="password" name="password" required>
        </label>
        <div class="full actions">
            <button class="btn" type="submit">Create visitor</button>
            <a class="btn secondary" href="{{ route('admin.visitors.index') }}">Cancel</a>
        </div>
    </form>
</div>
@endsection
