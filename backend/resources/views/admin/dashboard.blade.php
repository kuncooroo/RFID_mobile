@extends('admin.layouts.app')

@section('title', 'Dashboard')
@section('heading', 'Dashboard')
@section('subheading', 'Gerbang, saldo kartu, dan toko di aplikasi pengunjung, untuk hari ini.')

@section('content')
<div class="stats">
    <div class="stat-card"><span>Tiket lolos</span><strong>{{ number_format($grantedToday) }}</strong></div>
    <div class="stat-card"><span>Tiket ditolak</span><strong>{{ number_format($deniedToday) }}</strong></div>
    @if($showOps)
        <div class="stat-card"><span>Kartu belum terhubung</span><strong>{{ number_format($unboundCards) }}</strong></div>
    @endif
    @if($showFinance)
        <div class="stat-card"><span>Pendapatan tiket</span><strong>{{ number_format($revenue, 0, ',', '.') }}</strong><small class="stat-delta flat">Saldo kartu yang terpakai di gerbang</small></div>
        <div class="stat-card"><span>Omzet toko</span><strong>{{ number_format($todayMoney['shop'], 0, ',', '.') }}</strong><small class="stat-delta flat">Pesanan yang sudah dibayar</small></div>
        <div class="stat-card"><span>Top-up masuk</span><strong>{{ number_format($todayMoney['topup'], 0, ',', '.') }}</strong><small class="stat-delta flat">Masih milik pengunjung, bukan pendapatan</small></div>
        <div class="stat-card"><span>Laba tiket</span><strong>{{ number_format($profit, 0, ',', '.') }}</strong><small class="stat-delta flat">Margin {{ number_format($margin, 1, ',', '.') }}% · HPP {{ number_format($hpp, 0, ',', '.') }}</small></div>
    @endif
</div>

@if($showCashier)
<div class="panel">
    <div class="panel-header">
        <h2>Shift kasir</h2>
        <a class="btn secondary sm" href="{{ route('admin.cashier') }}">Buka kasir</a>
    </div>
    @if($openShift)
        <p>Shift terbuka sejak {{ $openShift->opened_at?->format('H:i') }}. Top-up tunai shift ini {{ number_format($shiftTopup, 0, ',', '.') }}. Uang yang seharusnya ada {{ number_format((float) $openShift->opening_float + $shiftTopup, 0, ',', '.') }}.</p>
    @else
        <p class="muted">Belum ada shift terbuka. Buka shift sebelum menerima uang tunai dari pengunjung.</p>
    @endif
</div>
@endif

@if($showBooks && $balance)
<div class="panel">
    <div class="panel-header">
        <h2>Cek saldo kartu</h2>
        <a class="btn secondary sm" href="{{ route('admin.cashflow') }}">Arus uang</a>
    </div>
    <p>
        Saldo kartu aktif {{ number_format($balance['active_balance'], 0, ',', '.') }}.
        Buku saldo {{ number_format($balance['book'], 0, ',', '.') }}.
        @if(abs($balance['balance_gap']) < 0.01)
            Keduanya sesuai.
        @else
            Selisih {{ number_format($balance['balance_gap'], 0, ',', '.') }}.
        @endif
        Selisih tiket {{ number_format($balance['ticket_gap'], 0, ',', '.') }}.
    </p>
</div>
@endif

@if($showFinance)
<div class="panel">
    <div class="panel-header">
        <h2>HPP lokasi</h2>
        <a class="btn secondary sm" href="{{ route('admin.analytics') }}">Analitik 7 hari</a>
    </div>
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>Lokasi</th>
                <th>Tarif</th>
                <th>HPP</th>
            </tr>
            </thead>
            <tbody>
            @forelse($locations as $location)
                <tr>
                    <td>{{ $location->name }}</td>
                    <td>{{ number_format((float) $location->fare_amount, 0, ',', '.') }}</td>
                    <td>{{ number_format((float) $location->cost_amount, 0, ',', '.') }}</td>
                </tr>
            @empty
                <tr><td colspan="3">Belum ada lokasi gerbang.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
</div>
@endif

@if($showOps)
<div class="panel">
    <div class="panel-header">
        <h2>Saldo hampir habis</h2>
        <span class="muted">Di bawah dua kali tarif {{ number_format($fare, 0, ',', '.') }}</span>
    </div>
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>Kartu</th>
                <th>Pemegang</th>
                <th>Saldo</th>
                <th>Status</th>
            </tr>
            </thead>
            <tbody>
            @forelse($lowCards as $card)
                <tr>
                    <td><code>{{ $card->rfid_uid }}</code></td>
                    <td>{{ $card->user?->name ?? 'Belum terhubung' }}</td>
                    <td>{{ number_format((float) $card->balance, 0, ',', '.') }}</td>
                    <td>
                        @if((float) $card->balance < $fare)
                            <span class="badge danger">Tidak cukup</span>
                        @else
                            <span class="badge warn">Hampir habis</span>
                        @endif
                    </td>
                </tr>
            @empty
                <tr><td colspan="4">Tidak ada kartu dengan saldo tipis.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
</div>

<div class="panel">
    <div class="panel-header">
        <h2>Tap terbaru</h2>
        <a class="btn secondary sm" href="{{ route('admin.rfid.scans') }}">Log scan</a>
    </div>
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>Waktu</th>
                <th>Pengunjung</th>
                <th>UID</th>
                <th>Lokasi</th>
                <th>Hasil</th>
                <th>Tarif</th>
            </tr>
            </thead>
            <tbody>
            @forelse($recentTaps as $tap)
                <tr>
                    <td>{{ $tap->checked_in_at?->format('Y-m-d H:i') }}</td>
                    <td>{{ $tap->user?->name ?? 'Kartu tanpa identitas' }}</td>
                    <td><code>{{ $tap->rfidMember?->rfid_uid ?? '—' }}</code></td>
                    <td>{{ $tap->location?->name ?? '—' }}</td>
                    <td>
                        @if($tap->status === 'success')
                            <span class="badge ok">Lolos</span>
                        @else
                            <span class="badge danger">Ditolak</span>
                        @endif
                    </td>
                    <td>{{ number_format((float) $tap->amount_charged, 0, ',', '.') }}</td>
                </tr>
            @empty
                <tr><td colspan="6">Belum ada tap gerbang.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
</div>
@endif

@if($showExperiences)
<div class="panel">
    <div class="panel-header">
        <h2>Experience terbaru</h2>
        <a class="btn secondary sm" href="{{ route('admin.experiences.index') }}">Semua experience</a>
    </div>
    @if($recentExperiences->isEmpty() && $recentCaptures->isEmpty())
        <p class="muted">Belum ada gambar experience.</p>
    @else
        <div class="gallery">
            @foreach($recentExperiences as $experience)
                <article class="gallery-card">
                    <img src="{{ route('admin.experiences.image', [$experience->user_id, $experience]) }}" alt="{{ $experience->title ?: 'Experience' }}">
                    <div class="meta">
                        <strong>{{ $experience->user?->name ?? 'Pengunjung' }}</strong>
                        <div class="muted">{{ $experience->title ?: 'Tanpa judul' }}</div>
                    </div>
                </article>
            @endforeach
            @foreach($recentCaptures as $capture)
                @if($capture->user)
                    <article class="gallery-card">
                        <img src="{{ route('admin.experiences.capture', [$capture->user_id, $capture]) }}" alt="Foto gerbang">
                        <div class="meta">
                            <strong>{{ $capture->user->name }}</strong>
                            <div class="muted">Foto gerbang</div>
                        </div>
                    </article>
                @endif
            @endforeach
        </div>
    @endif
</div>
@endif
@endsection
