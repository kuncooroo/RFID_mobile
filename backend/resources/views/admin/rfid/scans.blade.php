@extends('admin.layouts.app')

@section('title', 'RFID Scan Log')
@section('heading', 'RFID visit log')
@section('subheading', 'Kunjungan RFID yang tercatat (tanpa face capture).')

@section('content')
<div class="toolbar">
    <form method="GET" action="{{ route('admin.rfid.scans') }}" class="toolbar-form">
        <input class="search" type="search" name="q" value="{{ $q ?? '' }}" placeholder="Search visitor, RFID UID, member code…">
        <select name="status" class="search" style="max-width: 180px;">
            <option value="">All statuses</option>
            <option value="success" @selected(($status ?? '') === 'success')>success</option>
            <option value="failed" @selected(($status ?? '') === 'failed')>failed</option>
        </select>
        <button class="btn secondary" type="submit">Filter</button>
    </form>
</div>

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
                    <td>{{ $scan->user?->name ?? '—' }}</td>
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
                <tr><td colspan="6">No visits yet.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
    <div class="pagination">{{ $scans->links('admin.partials.pagination') }}</div>
</div>
@endsection
