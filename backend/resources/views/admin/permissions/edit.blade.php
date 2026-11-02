@extends('admin.layouts.app')

@section('title', 'Izin peran')
@section('heading', 'Izin peran')
@section('subheading', 'Centang izin pada pertemuan kolom peran dan baris kemampuan.')

@section('content')
<form method="POST" action="{{ route('admin.permissions.update') }}">
    @csrf
    @method('PUT')
    <div class="panel">
        <div class="table-wrap">
            <table class="permission-matrix">
                <thead>
                <tr>
                    <th>Kemampuan</th>
                    @foreach($roles as $role)
                        <th>{{ $role->label() }}</th>
                    @endforeach
                </tr>
                </thead>
                <tbody>
                @foreach($catalog as $key => $label)
                    <tr>
                        <td>
                            <strong>{{ $label }}</strong>
                            <div class="muted">{{ $key }}</div>
                        </td>
                        @foreach($roles as $role)
                            @php
                                $locked = $role === \App\Enums\UserRole::Superadmin;
                                $checked = $locked || in_array($key, $granted[$role->value] ?? [], true);
                            @endphp
                            <td>
                                <input
                                    type="checkbox"
                                    name="permissions[{{ $role->value }}][{{ $key }}]"
                                    value="1"
                                    @checked($checked)
                                    @disabled($locked)
                                    aria-label="{{ $role->label() }} {{ $label }}"
                                >
                            </td>
                        @endforeach
                    </tr>
                @endforeach
                </tbody>
            </table>
        </div>
        <p class="muted">Superadmin selalu memiliki seluruh izin. Centang pada peran lain menentukan halaman yang boleh dibuka.</p>
        <div class="actions">
            <button class="btn" type="submit">Simpan izin</button>
        </div>
    </div>
</form>
@endsection
