@extends('admin.layouts.app')

@section('title', 'Bind RFID Card')
@section('heading', 'Bind RFID Card')
@section('subheading', 'Kasir: tempel kartu, hubungkan ke pengunjung. Nomor 16 digit untuk aplikasi dibuat otomatis.')

@section('content')
<div class="panel">
    <form method="POST" action="{{ route('admin.rfid.bind.store') }}" class="form-grid" id="rfid-bind-form">
        @csrf

        <label class="full">
            Visitor
            <select name="user_id" required>
                <option value="">Select visitor...</option>
                @foreach($visitors as $visitor)
                    <option value="{{ $visitor->id }}" @selected((int) old('user_id', $selectedUserId) === $visitor->id)>
                        #{{ $visitor->id }} — {{ $visitor->name }}
                        @if($visitor->rfidMember)
                            (current: {{ $visitor->rfidMember->rfid_uid }})
                        @endif
                    </option>
                @endforeach
            </select>
        </label>

        <label class="full">
            RFID UID
            <input
                type="text"
                name="rfid_uid"
                id="rfid_uid"
                value="{{ old('rfid_uid') }}"
                placeholder="Tap card on USB reader..."
                required
                autocomplete="off"
                autofocus
            >
            <span class="help">USB keyboard-wedge readers type the UID then send Enter. Focus stays here while you tap.</span>
        </label>

        <label>
            Member code (optional)
            <input type="text" name="member_code" value="{{ old('member_code') }}" placeholder="Auto-generated if empty">
        </label>

        <label style="align-content:end;">
            <span style="display:flex;align-items:center;gap:8px;font-weight:600;">
                <input type="checkbox" name="is_active" value="1" @checked(old('is_active', true)) style="width:auto;">
                Card active
            </span>
        </label>

        <div class="full actions">
            <button class="btn" type="submit">Hubungkan ke pengunjung</button>
            <a class="btn secondary" href="{{ route('admin.visitors.index') }}">Back to visitors</a>
        </div>
    </form>
</div>

<div class="panel" style="margin-top: 16px;">
    <h2 style="margin-top: 0;">Catat kartu stok</h2>
    <p class="help">Untuk kartu yang belum punya pemilik. Nomor 16 digit dipakai di aplikasi, atau pengunjung daftar sendiri di kiosk.</p>
    <form method="POST" action="{{ route('admin.rfid.stock') }}" class="form-grid">
        @csrf
        <label class="full">
            RFID UID
            <input
                type="text"
                name="rfid_uid"
                id="stock_rfid_uid"
                value="{{ old('rfid_uid') }}"
                placeholder="Tap kartu stok..."
                required
                autocomplete="off"
            >
            @error('stock_rfid_uid')
                <span class="help" style="color:#c62828;">{{ $message }}</span>
            @enderror
        </label>
        <div class="full actions">
            <button class="btn secondary" type="submit">Simpan kartu stok</button>
        </div>
    </form>
</div>
@endsection

@push('scripts')
<script>
(() => {
  const input = document.getElementById('rfid_uid');
  if (!input) return;
  // Keep focus on the RFID field for USB wedge readers.
  input.focus();
  document.addEventListener('click', () => {
    const active = document.activeElement;
    if (active?.tagName === 'SELECT' || active?.tagName === 'BUTTON') return;
    if (active?.id === 'stock_rfid_uid') return;
    input.focus();
  });
})();
</script>
@endpush
