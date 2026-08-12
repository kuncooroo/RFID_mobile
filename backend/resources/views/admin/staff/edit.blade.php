@extends('admin.layouts.app')

@section('title', 'Edit staff')
@section('heading', 'Edit staff account')
@section('subheading', $staff->name)

@section('content')
<div class="panel">
    <form method="POST" action="{{ route('admin.staff.update', $staff) }}" class="form-grid">
        @csrf
        @method('PUT')
        <label>
            Name
            <input type="text" name="name" value="{{ old('name', $staff->name) }}" required>
        </label>
        <label>
            Email
            <input type="email" name="email" value="{{ old('email', $staff->email) }}" required>
        </label>
        <label>
            Phone
            <input type="text" name="phone" value="{{ old('phone', $staff->phone) }}">
        </label>
        <label>
            Role
            <select name="role" required>
                <option value="admin" @selected(old('role', $staff->role?->value) === 'admin')>Admin</option>
                <option value="superadmin" @selected(old('role', $staff->role?->value) === 'superadmin')>Superadmin</option>
            </select>
        </label>
        <label class="full">
            New password
            <input type="password" name="password" placeholder="Leave blank to keep current">
        </label>
        <div class="full actions">
            <button class="btn" type="submit">Save changes</button>
            <a class="btn secondary" href="{{ route('admin.staff.index') }}">Cancel</a>
        </div>
    </form>
</div>
@endsection
