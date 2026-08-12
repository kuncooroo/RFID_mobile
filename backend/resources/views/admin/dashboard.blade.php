@extends('admin.layouts.app')

@section('title', 'Dashboard')
@section('heading', 'Dashboard')
@section('subheading', 'Visitor overview, RFID status, and recent gate scans.')

@section('content')
<div class="stats">
    <div class="stat-card"><span>Visitors</span><strong>{{ number_format($visitorCount) }}</strong></div>
    <div class="stat-card"><span>Bound RFID</span><strong>{{ number_format($boundCards) }}</strong></div>
    <div class="stat-card"><span>Scans today</span><strong>{{ number_format($scanToday) }}</strong></div>
    <div class="stat-card"><span>Revenue today</span><strong>{{ number_format($revenueToday, 2) }}</strong></div>
</div>

<div class="panel">
    <div class="panel-header">
        <h2>Visitors & RFID status</h2>
        <div class="actions">
            <a class="btn secondary sm" href="{{ route('admin.visitors.create') }}">Add visitor</a>
            <a class="btn sm" href="{{ route('admin.rfid.bind') }}">Bind RFID Card</a>
        </div>
    </div>
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>Name</th>
                <th>Contact</th>
                <th>Member code</th>
                <th>RFID UID</th>
                <th>Card status</th>
                <th></th>
            </tr>
            </thead>
            <tbody>
            @forelse($visitors as $visitor)
                <tr>
                    <td>
                        <strong>{{ $visitor->name }}</strong>
                        @if($visitor->member)
                            <div class="muted">{{ $visitor->member->membership_tier }}</div>
                        @endif
                    </td>
                    <td>
                        <div>{{ $visitor->email ?? '—' }}</div>
                        <div class="muted">{{ $visitor->phone ?? '—' }}</div>
                    </td>
                    <td>{{ $visitor->rfidMember?->member_code ?? '—' }}</td>
                    <td><code>{{ $visitor->rfidMember?->rfid_uid ?? '—' }}</code></td>
                    <td>
                        @if($visitor->rfidMember?->is_active)
                            <span class="badge ok">Active</span>
                        @elseif($visitor->rfidMember)
                            <span class="badge warn">Inactive</span>
                        @else
                            <span class="badge danger">Unbound</span>
                        @endif
                    </td>
                    <td class="actions">
                        <a class="btn secondary sm" href="{{ route('admin.rfid.bind', ['user_id' => $visitor->id]) }}">Bind</a>
                        <a class="btn secondary sm" href="{{ route('admin.visitors.edit', $visitor) }}">Edit</a>
                    </td>
                </tr>
            @empty
                <tr><td colspan="6">No visitors yet.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
    <div class="pagination">{{ $visitors->links('admin.partials.pagination') }}</div>
</div>

<div class="panel">
    <div class="panel-header">
        <h2>Recent RFID scans</h2>
        <a class="btn secondary sm" href="{{ route('admin.rfid.scans') }}">View all</a>
    </div>
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>Time</th>
                <th>Visitor</th>
                <th>RFID UID</th>
                <th>Status</th>
                <th>Gate</th>
            </tr>
            </thead>
            <tbody>
            @forelse($recentScans as $scan)
                <tr>
                    <td>{{ $scan->created_at?->format('Y-m-d H:i') }}</td>
                    <td>{{ $scan->user?->name ?? '—' }}</td>
                    <td><code>{{ $scan->rfidMember?->rfid_uid ?? '—' }}</code></td>
                    <td><span class="badge neutral">{{ $scan->status }}</span></td>
                    <td>
                        @if($scan->gate_opened)
                            <span class="badge ok">Opened</span>
                        @else
                            <span class="badge warn">Closed</span>
                        @endif
                    </td>
                </tr>
            @empty
                <tr><td colspan="5">No scans yet.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection
