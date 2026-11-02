@php
    $diff = (float) ($delta['diff'] ?? 0);
    $percent = $delta['percent'] ?? null;
    $digits = (int) ($digits ?? 0);
    $text = ($diff > 0 ? '+' : '').number_format($diff, $digits, ',', '.');
@endphp
<small class="stat-delta {{ $diff > 0 ? 'up' : ($diff < 0 ? 'down' : 'flat') }}">
    @if(abs($diff) < 0.00001)
        Sama dengan 7 hari sebelumnya
    @elseif($percent === null)
        {{ $text }} dibanding 7 hari sebelumnya
    @else
        {{ $text }} ({{ ($percent > 0 ? '+' : '').number_format($percent, 1, ',', '.') }}%)
    @endif
</small>
