@extends('admin.layouts.app')

@section('title', 'Arus uang')
@section('heading', 'Arus uang')
@section('subheading', 'Uang yang masuk ke saldo kartu, saldo yang menjadi tiket, dan omzet toko.')

@section('content')
<div class="stats">
    <div class="stat-card"><span>Top-up hari ini</span><strong>{{ number_format($today['topup'], 0, ',', '.') }}</strong><small class="stat-delta flat">Masih saldo milik pengunjung</small></div>
    <div class="stat-card"><span>Potongan tiket hari ini</span><strong>{{ number_format($today['gate'], 0, ',', '.') }}</strong><small class="stat-delta flat">Menjadi pendapatan tiket</small></div>
    <div class="stat-card"><span>Omzet toko hari ini</span><strong>{{ number_format($today['shop'], 0, ',', '.') }}</strong><small class="stat-delta flat">Pesanan yang sudah dibayar</small></div>
</div>
<div class="stats">
    <div class="stat-card"><span>Top-up 7 hari</span><strong>{{ number_format($week['topup'], 0, ',', '.') }}</strong></div>
    <div class="stat-card"><span>Potongan tiket 7 hari</span><strong>{{ number_format($week['gate'], 0, ',', '.') }}</strong></div>
    <div class="stat-card"><span>Omzet toko 7 hari</span><strong>{{ number_format($week['shop'], 0, ',', '.') }}</strong></div>
</div>

<div class="panel" style="margin-bottom: 18px;">
    <div class="panel-header"><h2>Cek saldo</h2></div>
    <div class="stats" style="margin-bottom: 0;">
        <div class="stat-card"><span>Saldo kartu aktif</span><strong>{{ number_format($check['active_balance'], 0, ',', '.') }}</strong></div>
        <div class="stat-card"><span>Buku saldo</span><strong>{{ number_format($check['book'], 0, ',', '.') }}</strong><small class="stat-delta flat">Top-up {{ number_format($check['topup'], 0, ',', '.') }} − potongan {{ number_format($check['gate'], 0, ',', '.') }} + penyesuaian {{ number_format($check['adjustment'], 0, ',', '.') }}</small></div>
        <div class="stat-card">
            <span>Selisih saldo</span>
            <strong>{{ number_format($check['balance_gap'], 0, ',', '.') }}</strong>
            @if(abs($check['balance_gap']) < 0.01)
                <small class="stat-delta up">Sesuai dengan buku</small>
            @else
                <small class="stat-delta down">Ada saldo di luar buku, misalnya saldo awal kartu</small>
            @endif
        </div>
        <div class="stat-card">
            <span>Selisih tiket</span>
            <strong>{{ number_format($check['ticket_gap'], 0, ',', '.') }}</strong>
            <small class="stat-delta {{ abs($check['ticket_gap']) < 0.01 ? 'up' : 'down' }}">
                Pendapatan {{ number_format($check['ticket_revenue'], 0, ',', '.') }} dibanding potongan {{ number_format($check['gate_ledger'], 0, ',', '.') }}
            </small>
        </div>
    </div>
</div>

<div class="panel">
    <div class="panel-header">
        <h2>Gerakan saldo</h2>
        <form method="GET" action="{{ route('admin.cashflow') }}">
            <select name="reason" onchange="this.form.submit()">
                <option value="">Semua alasan</option>
                @foreach(['cashier_topup' => 'Top-up kasir', 'admin_topup' => 'Top-up admin', 'gate_debit' => 'Potongan tiket'] as $value => $label)
                    <option value="{{ $value }}" @selected($reason === $value)>{{ $label }}</option>
                @endforeach
            </select>
        </form>
    </div>
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>Waktu</th>
                <th>Kartu</th>
                <th>Pengunjung</th>
                <th>Nominal</th>
                <th>Alasan</th>
                <th>Saldo sesudahnya</th>
            </tr>
            </thead>
            <tbody>
            @forelse($ledgers as $ledger)
                <tr>
                    <td>{{ $ledger->created_at?->format('Y-m-d H:i') }}</td>
                    <td><code>{{ $ledger->rfidMember?->rfid_uid ?? '—' }}</code></td>
                    <td>{{ $ledger->user?->name ?? 'Kartu tanpa identitas' }}</td>
                    <td>{{ number_format((float) $ledger->delta, 0, ',', '.') }}</td>
                    <td>{{ \App\Models\WalletLedger::reasonLabel($ledger->reason) }}</td>
                    <td>{{ number_format((float) $ledger->balance_after, 0, ',', '.') }}</td>
                </tr>
            @empty
                <tr><td colspan="6">Belum ada gerakan saldo.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
    <div class="pagination">{{ $ledgers->links('admin.partials.pagination') }}</div>
</div>
@endsection
