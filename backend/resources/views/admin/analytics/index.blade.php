@extends('admin.layouts.app')

@section('title', 'Analytics')
@section('heading', 'Analytics')
@section('subheading', 'Global visits and revenue (last 7 days).')

@section('content')
<div class="stats">
    <div class="stat-card"><span>Visitors</span><strong>{{ number_format($stats['visitors']) }}</strong></div>
    <div class="stat-card"><span>Scans (7d)</span><strong>{{ number_format($stats['scans_7d']) }}</strong></div>
    <div class="stat-card"><span>Orders (7d)</span><strong>{{ number_format($stats['orders_7d']) }}</strong></div>
    <div class="stat-card"><span>Revenue (7d)</span><strong>{{ number_format($stats['revenue_7d'], 2) }}</strong></div>
</div>

<div class="panel">
    <div class="panel-header"><h2>Gate visits</h2></div>
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
    <div class="panel-header"><h2>Revenue</h2></div>
    @php $maxRev = max(1, $revenue->max('total')); @endphp
    <div class="chart-bars">
        @foreach($revenue as $point)
            <div class="bar-wrap">
                <div class="bar" style="height: {{ max(8, ($point['total'] / $maxRev) * 150) }}px" title="{{ number_format($point['total'], 2) }}"></div>
                <small>{{ $point['label'] }}</small>
                <small>{{ number_format($point['total'], 0) }}</small>
            </div>
        @endforeach
    </div>
</div>
@endsection
