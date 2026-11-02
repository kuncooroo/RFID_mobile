@extends('admin.layouts.app')

@section('title', 'Kasir')
@section('heading', 'Kasir')
@section('subheading', 'Top-up tunai untuk pengunjung yang tidak mengisi saldo sendiri. Uang yang diterima dicocokkan saat shift ditutup.')

@section('content')
@if($canOperate)
    @if($openShift)
        <div class="stats">
            <div class="stat-card"><span>Shift terbuka</span><strong>{{ $openShift->opened_at?->format('H:i') }}</strong><small class="stat-delta flat">{{ $openShift->opened_at?->format('Y-m-d') }}</small></div>
            <div class="stat-card"><span>Modal awal</span><strong>{{ number_format((float) $openShift->opening_float, 0, ',', '.') }}</strong></div>
            <div class="stat-card"><span>Uang yang seharusnya ada</span><strong>{{ number_format($shiftCash, 0, ',', '.') }}</strong><small class="stat-delta flat">Modal awal + top-up tunai shift ini</small></div>
        </div>

        <div class="panel" style="margin-bottom: 18px;">
            <div class="panel-header"><h2>Terima top-up tunai</h2></div>
            <form method="POST" action="{{ route('admin.cashier.topup') }}" class="form-grid">
                @csrf
                <label>
                    UID, nomor kartu, atau kode member
                    <input type="text" name="card" value="{{ old('card') }}" required>
                </label>
                <label>
                    Nominal tunai
                    <input type="number" name="amount" min="0.01" step="0.01" value="{{ old('amount') }}" required>
                </label>
                <div class="full actions">
                    <button class="btn" type="submit">Tambah saldo</button>
                </div>
            </form>
        </div>

        <div class="panel" style="margin-bottom: 18px;">
            <div class="panel-header"><h2>Top-up shift ini</h2></div>
            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Waktu</th>
                        <th>Kartu</th>
                        <th>Pengunjung</th>
                        <th>Nominal</th>
                        <th>Saldo sesudahnya</th>
                    </tr>
                    </thead>
                    <tbody>
                    @forelse($movements as $movement)
                        <tr>
                            <td>{{ $movement->created_at?->format('H:i') }}</td>
                            <td><code>{{ $movement->rfidMember?->rfid_uid ?? '—' }}</code></td>
                            <td>{{ $movement->user?->name ?? 'Kartu tanpa identitas' }}</td>
                            <td>{{ number_format((float) $movement->delta, 0, ',', '.') }}</td>
                            <td>{{ number_format((float) $movement->balance_after, 0, ',', '.') }}</td>
                        </tr>
                    @empty
                        <tr><td colspan="5">Belum ada top-up pada shift ini.</td></tr>
                    @endforelse
                    </tbody>
                </table>
            </div>
        </div>

        <div class="panel" style="margin-bottom: 18px;">
            <div class="panel-header"><h2>Tutup shift</h2></div>
            <p class="muted">Hitung uang di laci, lalu isi jumlahnya. Selisih = uang dihitung − uang yang seharusnya ada.</p>
            <form method="POST" action="{{ route('admin.cashier.close', $openShift) }}" class="form-grid">
                @csrf
                <label>
                    Uang dihitung
                    <input type="number" name="cash_counted" min="0" step="0.01" required>
                </label>
                <label>
                    Catatan
                    <input type="text" name="note" maxlength="500">
                </label>
                <div class="full actions">
                    <button class="btn" type="submit">Tutup shift</button>
                </div>
            </form>
        </div>
    @else
        <div class="panel" style="margin-bottom: 18px;">
            <div class="panel-header"><h2>Buka shift</h2></div>
            <p class="muted">Isi modal yang ada di laci sebelum menerima top-up.</p>
            <form method="POST" action="{{ route('admin.cashier.open') }}" class="form-grid">
                @csrf
                <label>
                    Modal awal
                    <input type="number" name="opening_float" min="0" step="0.01" value="0" required>
                </label>
                <div class="actions" style="align-self: end;">
                    <button class="btn" type="submit">Buka shift</button>
                </div>
            </form>
        </div>
    @endif
@endif

<div class="panel">
    <div class="panel-header"><h2>Riwayat shift</h2></div>
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>Kasir</th>
                <th>Buka</th>
                <th>Tutup</th>
                <th>Modal</th>
                <th>Seharusnya</th>
                <th>Dihitung</th>
                <th>Selisih</th>
            </tr>
            </thead>
            <tbody>
            @forelse($shifts as $row)
                @php
                    $shift = $row['model'];
                    $gap = $shift->cash_counted === null ? null : (float) $shift->cash_counted - $row['expected'];
                @endphp
                <tr>
                    <td>{{ $shift->admin?->name ?? '—' }}</td>
                    <td>{{ $shift->opened_at?->format('Y-m-d H:i') }}</td>
                    <td>{{ $shift->closed_at?->format('Y-m-d H:i') ?? 'Masih terbuka' }}</td>
                    <td>{{ number_format((float) $shift->opening_float, 0, ',', '.') }}</td>
                    <td>{{ number_format($row['expected'], 0, ',', '.') }}</td>
                    <td>{{ $shift->cash_counted === null ? '—' : number_format((float) $shift->cash_counted, 0, ',', '.') }}</td>
                    <td>
                        @if($gap === null)
                            <span class="badge warn">Belum dihitung</span>
                        @elseif(abs($gap) < 0.01)
                            <span class="badge ok">Sesuai</span>
                        @else
                            <span class="badge {{ $gap < 0 ? 'danger' : 'warn' }}">{{ number_format($gap, 0, ',', '.') }}</span>
                        @endif
                    </td>
                </tr>
            @empty
                <tr><td colspan="7">Belum ada shift kasir.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection
