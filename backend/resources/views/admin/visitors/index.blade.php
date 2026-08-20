@extends('admin.layouts.app')

@section('title', 'Visitors')
@section('heading', 'Visitor management')
@section('subheading', 'Kelola visitor, RFID, points, dan face enrollment.')

@section('content')
<div class="toolbar">
    <form method="GET" action="{{ route('admin.visitors.index') }}" class="toolbar-form">
        <input class="search" type="search" name="q" value="{{ $q }}" placeholder="Search name, email, phone, RFID UID…">
        <button class="btn secondary" type="submit">Search</button>
    </form>
    <a class="btn" href="{{ route('admin.visitors.create') }}">Add visitor</a>
</div>

<div class="panel">
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>No</th>
                <th>Name</th>
                <th>Contact</th>
                <th>RFID</th>
                <th>Face</th>
                <th>Points</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            @forelse($visitors as $visitor)
                @php
                    $faceCount = $visitor->faceEnrollments
                        ->whereIn('pose', ['front', 'right', 'left'])
                        ->count();
                @endphp
                <tr>
                    <td>{{ ($visitors->firstItem() ?? 0) + $loop->index }}</td>
                    <td>
                        <div class="avatar-chip">
                            <span class="dot">{{ strtoupper(substr($visitor->name, 0, 1)) }}</span>
                            <strong>{{ $visitor->name }}</strong>
                        </div>
                    </td>
                    <td>
                        <div>{{ $visitor->email ?? '—' }}</div>
                        <div class="muted">{{ $visitor->phone ?? '—' }}</div>
                    </td>
                    <td>
                        <div><code>{{ $visitor->rfidMember?->rfid_uid ?? '—' }}</code></div>
                        <div class="muted">{{ $visitor->rfidMember?->member_code ?? '' }}</div>
                    </td>
                    <td>
                        @if($faceCount >= 3)
                            <span class="badge ok">{{ $faceCount }}/3</span>
                        @elseif($faceCount > 0)
                            <span class="badge warn">{{ $faceCount }}/3</span>
                        @else
                            <span class="badge muted">0/3</span>
                        @endif
                    </td>
                    <td>{{ (int) ($visitor->member?->points ?? 0) }}</td>
                    <td>
                        @if($visitor->rfidMember?->is_active)
                            <span class="badge ok">Bound</span>
                        @elseif($visitor->rfidMember)
                            <span class="badge warn">Inactive</span>
                        @else
                            <span class="badge danger">No card</span>
                        @endif
                    </td>
                    <td class="actions">
                        <a class="btn secondary sm" href="{{ route('admin.visitors.edit', $visitor) }}">Edit</a>
                        <form method="POST" action="{{ route('admin.visitors.destroy', $visitor) }}" onsubmit="return confirm('Delete this visitor?')">
                            @csrf
                            @method('DELETE')
                            <button class="btn danger sm" type="submit">Delete</button>
                        </form>
                    </td>
                </tr>
            @empty
                <tr><td colspan="8">No visitors found.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
    <div class="pagination">{{ $visitors->links('admin.partials.pagination') }}</div>
</div>
@endsection
