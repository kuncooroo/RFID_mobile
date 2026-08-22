@extends('admin.layouts.app')

@section('title', 'RFID Scan Log')
@section('heading', 'RFID visit log')
@section('subheading', 'Kunjungan RFID yang tercatat (tanpa face capture).')

@section('content')
<div class="panel" style="margin-bottom: 14px;">
    <form method="GET" action="{{ route('admin.rfid.scans') }}" class="filter-form">
        <div class="filter-row">
            <label>
                Search
                <input class="search" type="search" name="q" value="{{ $q ?? '' }}" placeholder="Visitor, RFID UID, member code…">
            </label>
            <label>
                Status
                <select name="status">
                    <option value="">All statuses</option>
                    <option value="success" @selected(($status ?? '') === 'success')>success</option>
                    <option value="failed" @selected(($status ?? '') === 'failed')>failed</option>
                </select>
            </label>
            <label>
                From
                <input type="date" name="date_from" value="{{ $dateFrom ?? '' }}">
            </label>
            <label>
                To
                <input type="date" name="date_to" value="{{ $dateTo ?? '' }}">
            </label>
        </div>
        <div class="filter-actions">
            <div class="preset-chips">
                <a class="chip {{ ($preset ?? '') === 'today' ? 'active' : '' }}" href="{{ route('admin.rfid.scans', ['preset' => 'today', 'q' => $q, 'status' => $status]) }}">Today</a>
                <a class="chip {{ ($preset ?? '') === '7d' ? 'active' : '' }}" href="{{ route('admin.rfid.scans', ['preset' => '7d', 'q' => $q, 'status' => $status]) }}">Last 7 days</a>
                <a class="chip {{ ($preset ?? '') === '30d' ? 'active' : '' }}" href="{{ route('admin.rfid.scans', ['preset' => '30d', 'q' => $q, 'status' => $status]) }}">Last 30 days</a>
                <a class="chip {{ ($preset ?? '') === 'month' ? 'active' : '' }}" href="{{ route('admin.rfid.scans', ['preset' => 'month', 'q' => $q, 'status' => $status]) }}">This month</a>
            </div>
            <div class="actions">
                <button class="btn secondary" type="submit">Apply filter</button>
                <a class="btn secondary" href="{{ route('admin.rfid.scans') }}">Reset</a>
            </div>
        </div>
    </form>
</div>

@if(($dateFrom ?? null) || ($dateTo ?? null))
    <p class="muted" style="margin: 0 0 12px;">
        Showing visits
        @if($dateFrom ?? null)
            from <strong>{{ $dateFrom }}</strong>
        @endif
        @if($dateTo ?? null)
            to <strong>{{ $dateTo }}</strong>
        @endif
    </p>
@endif

<div class="panel">
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>No</th>
                <th>User</th>
                <th>RFID</th>
                <th>Time</th>
                <th>Points</th>
                <th>Status</th>
            </tr>
            </thead>
            <tbody>
            @forelse($scans as $scan)
                <tr>
                    <td>{{ ($scans->firstItem() ?? 0) + $loop->index }}</td>
                    <td>
                        @if($scan->user)
                            <a href="{{ route('admin.visitors.show', $scan->user) }}">{{ $scan->user->name }}</a>
                        @else
                            —
                        @endif
                    </td>
                    <td>
                        <div><code>{{ $scan->rfidMember?->rfid_uid ?? '—' }}</code></div>
                        <div class="muted">{{ $scan->rfidMember?->member_code ?? '' }}</div>
                    </td>
                    <td>{{ $scan->checked_in_at?->format('Y-m-d H:i:s') ?? $scan->created_at?->format('Y-m-d H:i:s') }}</td>
                    <td>
                        @if((int) $scan->points_awarded > 0)
                            <span class="badge ok">+{{ (int) $scan->points_awarded }}</span>
                        @else
                            <span class="muted">0</span>
                        @endif
                    </td>
                    <td><span class="badge {{ $scan->status === 'success' ? 'ok' : 'warn' }}">{{ $scan->status }}</span></td>
                </tr>
            @empty
                <tr><td colspan="6">No visits found for this filter.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
    <div class="pagination">{{ $scans->links('admin.partials.pagination') }}</div>
</div>
@endsection
