@extends('admin.layouts.app')

@section('title', 'Activity Log')
@section('heading', 'Activity log')
@section('subheading', 'Audit trail of admin dashboard actions.')

@section('content')
<div class="panel">
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>Time</th>
                <th>Actor</th>
                <th>Action</th>
                <th>Description</th>
                <th>IP</th>
            </tr>
            </thead>
            <tbody>
            @forelse($logs as $log)
                <tr>
                    <td>{{ $log->created_at?->format('Y-m-d H:i:s') }}</td>
                    <td>{{ $log->admin?->name ?? $log->user?->name ?? 'System' }}</td>
                    <td><span class="badge neutral">{{ $log->action }}</span></td>
                    <td>{{ $log->description }}</td>
                    <td>{{ $log->ip_address ?? '—' }}</td>
                </tr>
            @empty
                <tr><td colspan="5">No activity yet.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
    <div class="pagination">{{ $logs->links('admin.partials.pagination') }}</div>
</div>
@endsection
