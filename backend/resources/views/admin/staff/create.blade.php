@extends('admin.layouts.app')

@section('title', 'Add staff')
@section('heading', 'Add staff account')

@section('content')
<div class="panel">
    <form method="POST" action="{{ route('admin.staff.store') }}" class="form-grid">
        @csrf
        <label>
            Name
            <input type="text" name="name" value="{{ old('name') }}" required>
        </label>
        <label>
            Email
            <input type="email" name="email" value="{{ old('email') }}" required>
        </label>
        <label>
            Phone
            <input type="text" name="phone" value="{{ old('phone') }}">
        </label>
        <label>
            Role
            <select name="role" required>
                @foreach(\App\Enums\UserRole::cases() as $role)
                    @if($role->isStaff())
                        <option value="{{ $role->value }}" @selected(old('role') === $role->value)>{{ $role->label() }}</option>
                    @endif
                @endforeach
            </select>
        </label>
        <label class="full">
            Password
            <input type="password" name="password" required>
        </label>
        <div class="full actions">
            <button class="btn" type="submit">Create staff</button>
            <a class="btn secondary" href="{{ route('admin.staff.index') }}">Cancel</a>
        </div>
    </form>
</div>
@endsection
