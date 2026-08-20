@extends('admin.layouts.app')

@section('title', 'Edit visitor')
@section('heading', 'Edit visitor')
@section('subheading', $visitor->name)

@section('content')
<form method="POST" action="{{ route('admin.visitors.update', $visitor) }}" enctype="multipart/form-data" class="visitor-form">
    @csrf
    @method('PUT')
    <div class="panel visitor-form-panel">
        @include('admin.visitors._form')
        <div class="form-actions">
            <button class="btn" type="submit">Save changes</button>
            <a class="btn secondary" href="{{ route('admin.visitors.index') }}">Back to list</a>
            <a class="btn secondary" href="{{ route('admin.rfid.bind', ['user_id' => $visitor->id]) }}">Open RFID binder</a>
        </div>
    </div>
</form>
@endsection
