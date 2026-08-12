@extends('admin.layouts.app')

@section('title', 'Visitors')
@section('heading', 'Visitor management')
@section('subheading', 'CRUD for mobile app visitors and their RFID card status.')

@section('content')
<div class="toolbar">
    <form method="GET" action="{{ route('admin.visitors.index') }}">
        <input class="search" type="search" name="q" value="{{ $q }}" placeholder="Search name, email, phone, RFID UID...">
        <button class="btn secondary" type="submit">Search</button>
    </form>
    <a class="btn" href="{{ route('admin.visitors.create') }}">Add visitor</a>
    <a class="btn secondary" href="{{ route('admin.rfid.bind') }}">Bind RFID</a>
</div>

<div class="panel">
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Email / Phone</th>
                <th>RFID UID</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            @forelse($visitors as $visitor)
                <tr>
                    <td>{{ $visitor->id }}</td>
                    <td><strong>{{ $visitor->name }}</strong></td>
                    <td>
                        <div>{{ $visitor->email ?? '—' }}</div>
                        <div class="muted">{{ $visitor->phone ?? '—' }}</div>
                    </td>
                    <td><code>{{ $visitor->rfidMember?->rfid_uid ?? '—' }}</code></td>
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
                        <a class="btn secondary sm" href="{{ route('admin.rfid.bind', ['user_id' => $visitor->id]) }}">Bind</a>
                        <a class="btn secondary sm" href="{{ route('admin.visitors.edit', $visitor) }}">Edit</a>
                        <form method="POST" action="{{ route('admin.visitors.destroy', $visitor) }}" onsubmit="return confirm('Delete this visitor?')">
                            @csrf
                            @method('DELETE')
                            <button class="btn danger sm" type="submit">Delete</button>
                        </form>
                    </td>
                </tr>
            @empty
                <tr><td colspan="6">No visitors found.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
    <div class="pagination">{{ $visitors->links('admin.partials.pagination') }}</div>
</div>
@endsection
