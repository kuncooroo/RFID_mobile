@extends('admin.layouts.app')

@section('title', 'Add visitor')
@section('heading', 'Add visitor')
@section('subheading', 'Buat akun visitor, bind RFID, dan upload face enrollment.')

@section('content')
<form method="POST" action="{{ route('admin.visitors.store') }}" enctype="multipart/form-data" class="visitor-form">
    @csrf
    <div class="panel visitor-form-panel">
        @include('admin.visitors._form')
        <div class="form-actions">
            <button class="btn" type="submit">Create visitor</button>
            <a class="btn secondary" href="{{ route('admin.visitors.index') }}">Cancel</a>
        </div>
    </div>
</form>
@endsection
