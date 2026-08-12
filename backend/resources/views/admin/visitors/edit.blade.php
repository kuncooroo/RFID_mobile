@extends('admin.layouts.app')

@section('title', 'Edit visitor')
@section('heading', 'Edit visitor')
@section('subheading', $visitor->name)

@section('content')
<div class="panel">
    <form method="POST" action="{{ route('admin.visitors.update', $visitor) }}" class="form-grid">
        @csrf
        @method('PUT')
        <label>
            Name
            <input type="text" name="name" value="{{ old('name', $visitor->name) }}" required>
        </label>
        <label>
            Email
            <input type="email" name="email" value="{{ old('email', $visitor->email) }}">
        </label>
        <label>
            Phone
            <input type="text" name="phone" value="{{ old('phone', $visitor->phone) }}">
        </label>
        <label>
            New password
            <input type="password" name="password" placeholder="Leave blank to keep current">
            <span class="help">Optional</span>
        </label>
        <div class="full">
            <p class="muted">
                Current RFID:
                <code>{{ $visitor->rfidMember?->rfid_uid ?? 'Not bound' }}</code>
                —
                <a href="{{ route('admin.rfid.bind', ['user_id' => $visitor->id]) }}">Bind / replace card</a>
            </p>
        </div>
        <div class="full actions">
            <button class="btn" type="submit">Save changes</button>
            <a class="btn secondary" href="{{ route('admin.visitors.index') }}">Cancel</a>
        </div>
    </form>
</div>
@endsection
