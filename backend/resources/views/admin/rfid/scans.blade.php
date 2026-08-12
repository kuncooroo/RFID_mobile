@extends('admin.layouts.app')

@section('title', 'RFID Scan Log')
@section('heading', 'RFID scan log')
@section('subheading', 'Real-time style feed of gate verification attempts from the mobile app.')

@section('content')
<div class="toolbar">
    <form method="GET" action="{{ route('admin.rfid.scans') }}">
        <select name="status">
            <option value="">All statuses</option>
            <option value="verified" @selected($status === 'verified')>verified</option>
            <option value="pending" @selected($status === 'pending')>pending</option>
            <option value="failed" @selected($status === 'failed')>failed</option>
        </select>
        <button class="btn secondary" type="submit">Filter</button>
    </form>
</div>

<div class="panel">
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>ID</th>
                <th>Time</th>
                <th>Visitor</th>
                <th>Member code</th>
                <th>RFID UID</th>
                <th>Status</th>
                <th>Gate</th>
                <th>Message</th>
            </tr>
            </thead>
            <tbody>
            @forelse($scans as $scan)
                <tr>
                    <td>{{ $scan->id }}</td>
                    <td>{{ $scan->verified_at?->format('Y-m-d H:i:s') ?? $scan->created_at?->format('Y-m-d H:i:s') }}</td>
                    <td>{{ $scan->user?->name ?? '—' }}</td>
                    <td>{{ $scan->rfidMember?->member_code ?? '—' }}</td>
                    <td><code>{{ $scan->rfidMember?->rfid_uid ?? '—' }}</code></td>
                    <td><span class="badge neutral">{{ $scan->status }}</span></td>
                    <td>
                        @if($scan->gate_opened)
                            <span class="badge ok">Opened</span>
                        @else
                            <span class="badge warn">No</span>
                        @endif
                    </td>
                    <td>{{ $scan->message ?? '—' }}</td>
                </tr>
            @empty
                <tr><td colspan="8">No scan logs yet.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
    <div class="pagination">{{ $scans->links('admin.partials.pagination') }}</div>
</div>
@endsection
