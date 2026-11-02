@extends('admin.layouts.app')

@section('title', 'Analitik')
@section('heading', 'Analitik')
@section('subheading', 'Tiket gerbang dan penjualan toko, 7 hari terakhir dibanding 7 hari sebelumnya.')

@section('content')
<h2 style="margin: 0 0 12px;">Tiket gerbang</h2>
<div class="stats">
    <div class="stat-card">
        <span>Tiket lolos</span>
        <strong>{{ number_format($ticket['tickets']) }}</strong>
        @include('admin.partials.delta', ['delta' => $ticketCompare['tickets']])
    </div>
    <div class="stat-card">
        <span>Tiket ditolak</span>
        <strong>{{ number_format($ticket['denied']) }}</strong>
        @include('admin.partials.delta', ['delta' => $ticketCompare['denied']])
    </div>
    <div class="stat-card">
        <span>Pendapatan tiket</span>
        <strong>{{ number_format($ticket['revenue'], 0, ',', '.') }}</strong>
        @include('admin.partials.delta', ['delta' => $ticketCompare['revenue']])
    </div>
    <div class="stat-card">
        <span>Laba tiket</span>
        <strong>{{ number_format($ticket['profit'], 0, ',', '.') }}</strong>
        @include('admin.partials.delta', ['delta' => $ticketCompare['profit']])
    </div>
</div>

<div class="stats">
    <div class="stat-card"><span>HPP tiket</span><strong>{{ number_format($ticket['hpp'], 0, ',', '.') }}</strong></div>
    <div class="stat-card"><span>Margin tiket</span><strong>{{ number_format($ticket['margin'], 1, ',', '.') }}%</strong></div>
    <div class="stat-card"><span>Proyeksi pendapatan 30 hari</span><strong>{{ number_format($ticket['projected_revenue'], 0, ',', '.') }}</strong></div>
    <div class="stat-card"><span>Proyeksi laba 30 hari</span><strong>{{ number_format($ticket['projected_profit'], 0, ',', '.') }}</strong></div>
</div>

<div class="stats">
    <div class="stat-card">
        <span>Kartu unik</span>
        <strong>{{ number_format($ticket['unique_cards']) }}</strong>
        @include('admin.partials.delta', ['delta' => $ticketCompare['unique_cards']])
    </div>
    <div class="stat-card">
        <span>Kunjungan berulang</span>
        <strong>{{ number_format($ticket['repeat_visits']) }}</strong>
        @include('admin.partials.delta', ['delta' => $ticketCompare['repeat_visits']])
    </div>
    <div class="stat-card">
        <span>Jam tersibuk</span>
        <strong>{{ $ticket['busiest_hour']['label'] ?? '—' }}</strong>
        <small class="stat-delta flat">{{ $ticket['busiest_hour'] ? number_format($ticket['busiest_hour']['count']).' tiket lolos' : 'Belum ada tiket lolos' }}</small>
    </div>
</div>

<div class="panel" style="margin-bottom: 18px;">
    <div class="panel-header"><h2>Alasan tiket ditolak</h2></div>
    <div class="table-wrap">
        <table>
            <thead><tr><th>Alasan</th><th>Jumlah</th></tr></thead>
            <tbody>
            @forelse($ticket['reasons'] as $reason)
                <tr>
                    <td>{{ $reason['label'] }}</td>
                    <td>{{ number_format($reason['count']) }}</td>
                </tr>
            @empty
                <tr><td colspan="2">Tidak ada tiket ditolak pada 7 hari ini.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
</div>

<div class="panel" style="margin-bottom: 18px;">
    <div class="panel-header"><h2>Rincian per lokasi</h2></div>
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>Lokasi</th>
                <th>Tiket</th>
                <th>Pendapatan</th>
                <th>HPP</th>
                <th>Laba</th>
            </tr>
            </thead>
            <tbody>
            @forelse($ticket['locations'] as $location)
                <tr>
                    <td>{{ $location['name'] }}</td>
                    <td>{{ number_format($location['tickets']) }}</td>
                    <td>{{ number_format($location['revenue'], 0, ',', '.') }}</td>
                    <td>{{ number_format($location['hpp'], 0, ',', '.') }}</td>
                    <td>{{ number_format($location['profit'], 0, ',', '.') }}</td>
                </tr>
            @empty
                <tr><td colspan="5">Belum ada lokasi gerbang.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
</div>

<div class="panel" style="margin-bottom: 18px;">
    <div class="panel-header"><h2>Dasar perhitungan tiket</h2></div>
    <p>Pendapatan adalah tarif yang terpotong dari tiket lolos. HPP adalah biaya per tiket dikali jumlah tiket di lokasi itu. Laba = pendapatan − HPP. Kartu unik adalah kartu yang lolos minimal sekali. Kunjungan berulang adalah tiket lolos di luar kunjungan pertama tiap kartu. Proyeksi 30 hari memakai rata-rata 7 hari terakhir dikali 30.</p>
</div>

@if(auth('admin')->user()?->allows('finance.manage'))
<div class="panel" style="margin-bottom: 18px;">
    <div class="panel-header"><h2>HPP per lokasi</h2></div>
    <form method="POST" action="{{ route('admin.analytics.costs') }}" class="form-grid">
        @csrf
        @method('PUT')
        @forelse($locations as $location)
            <label>
                {{ $location->name }} (tarif {{ number_format((float) $location->fare_amount, 0, ',', '.') }})
                <input type="number" name="costs[{{ $location->id }}]" min="0" step="0.01" value="{{ old('costs.'.$location->id, $location->cost_amount) }}" required>
            </label>
        @empty
            <p class="muted">Belum ada lokasi gerbang.</p>
        @endforelse
        @if($locations->isNotEmpty())
            <div class="full actions">
                <button class="btn" type="submit">Simpan HPP</button>
            </div>
        @endif
    </form>
</div>
@endif

<div class="panel">
    <div class="panel-header"><h2>Tiket per hari</h2></div>
    @php $maxVisit = max(1, $visits->max('count')); @endphp
    <div class="chart-bars">
        @foreach($visits as $point)
            <div class="bar-wrap">
                <div class="bar" style="height: {{ max(8, ($point['count'] / $maxVisit) * 150) }}px" title="{{ $point['count'] }}"></div>
                <small>{{ $point['label'] }}</small>
                <small>{{ $point['count'] }}</small>
            </div>
        @endforeach
    </div>
</div>

<div class="panel">
    <div class="panel-header"><h2>Pendapatan tiket per hari</h2></div>
    @php $maxRev = max(1, $revenue->max('total')); @endphp
    <div class="chart-bars">
        @foreach($revenue as $point)
            <div class="bar-wrap">
                <div class="bar" style="height: {{ max(8, ($point['total'] / $maxRev) * 150) }}px" title="{{ number_format($point['total'], 2) }}"></div>
                <small>{{ $point['label'] }}</small>
                <small>{{ number_format($point['total'], 0, ',', '.') }}</small>
            </div>
        @endforeach
    </div>
</div>

<h2 style="margin: 8px 0 12px;">Penjualan toko</h2>
<div class="stats">
    <div class="stat-card">
        <span>Omzet toko</span>
        <strong>{{ number_format($shop['revenue'], 0, ',', '.') }}</strong>
        @include('admin.partials.delta', ['delta' => $shopCompare['revenue']])
    </div>
    <div class="stat-card">
        <span>Pesanan berbayar</span>
        <strong>{{ number_format($shop['orders']) }}</strong>
        @include('admin.partials.delta', ['delta' => $shopCompare['orders']])
    </div>
    <div class="stat-card">
        <span>Rata-rata nilai pesanan</span>
        <strong>{{ number_format($shop['average'], 0, ',', '.') }}</strong>
        @include('admin.partials.delta', ['delta' => $shopCompare['average']])
    </div>
    <div class="stat-card">
        <span>Laba toko</span>
        <strong>{{ number_format($shop['profit'], 0, ',', '.') }}</strong>
        @include('admin.partials.delta', ['delta' => $shopCompare['profit']])
    </div>
</div>

<div class="stats">
    <div class="stat-card"><span>HPP toko</span><strong>{{ number_format($shop['hpp'], 0, ',', '.') }}</strong></div>
    <div class="stat-card"><span>Margin toko</span><strong>{{ number_format($shop['margin'], 1, ',', '.') }}%</strong></div>
    <div class="stat-card"><span>Batal</span><strong>{{ number_format($shop['cancelled_count']) }}</strong><small class="stat-delta flat">{{ number_format($shop['cancelled_total'], 0, ',', '.') }} tidak masuk omzet</small></div>
    <div class="stat-card"><span>Refund</span><strong>{{ number_format($shop['refunded_count']) }}</strong><small class="stat-delta flat">{{ number_format($shop['refunded_total'], 0, ',', '.') }} tidak masuk omzet</small></div>
</div>

<div class="panel" style="margin-bottom: 18px;">
    <div class="panel-header"><h2>Dasar perhitungan toko</h2></div>
    <p>Omzet menjumlahkan pesanan berstatus dibayar, diproses, dikirim, atau selesai. Pesanan menunggu ({{ number_format($shop['pending_count']) }}), batal, dan refund tidak masuk omzet. HPP memakai biaya pokok produk dikali jumlah terjual. Laba toko = omzet − HPP. Isi HPP di data produk supaya margin ini mengikuti biaya yang sebenarnya.</p>
</div>

<div class="panel">
    <div class="panel-header"><h2>Omzet toko per hari</h2></div>
    @php $maxShop = max(1, $shopDaily->max('total')); @endphp
    <div class="chart-bars">
        @foreach($shopDaily as $point)
            <div class="bar-wrap">
                <div class="bar" style="height: {{ max(8, ($point['total'] / $maxShop) * 150) }}px" title="{{ number_format($point['total'], 2) }}"></div>
                <small>{{ $point['label'] }}</small>
                <small>{{ number_format($point['total'], 0, ',', '.') }}</small>
            </div>
        @endforeach
    </div>
</div>

<div class="panel" style="margin-bottom: 18px;">
    <div class="panel-header"><h2>Produk terlaris</h2></div>
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>Produk</th>
                <th>Terjual</th>
                <th>Nilai jual</th>
                <th>HPP</th>
                <th>Laba</th>
            </tr>
            </thead>
            <tbody>
            @forelse($shop['products'] as $product)
                <tr>
                    <td>{{ $product['name'] }}</td>
                    <td>{{ number_format($product['qty']) }}</td>
                    <td>{{ number_format($product['revenue'], 0, ',', '.') }}</td>
                    <td>{{ number_format($product['hpp'], 0, ',', '.') }}</td>
                    <td>{{ number_format($product['profit'], 0, ',', '.') }}</td>
                </tr>
            @empty
                <tr><td colspan="5">Belum ada produk terjual pada pesanan berbayar.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
</div>

<h2 style="margin: 8px 0 12px;">Gabungan tiket dan toko</h2>
<div class="stats">
    <div class="stat-card">
        <span>Pendapatan gabungan</span>
        <strong>{{ number_format($combined['revenue'], 0, ',', '.') }}</strong>
        @include('admin.partials.delta', ['delta' => $combinedCompare['revenue']])
    </div>
    <div class="stat-card">
        <span>Laba gabungan</span>
        <strong>{{ number_format($combined['profit'], 0, ',', '.') }}</strong>
        @include('admin.partials.delta', ['delta' => $combinedCompare['profit']])
    </div>
    <div class="stat-card"><span>Margin gabungan</span><strong>{{ number_format($combined['margin'], 1, ',', '.') }}%</strong></div>
</div>
<p class="muted">Pendapatan gabungan = pendapatan tiket + omzet toko. Top-up kartu tidak dijumlahkan di sini karena saldo itu masih milik pengunjung.</p>
@endsection
