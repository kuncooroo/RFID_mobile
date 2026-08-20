@extends('admin.layouts.app')

@section('title', 'Orders')
@section('heading', 'Orders')
@section('subheading', 'Orders placed from the Kutuku mobile app.')

@section('content')
<div class="toolbar">
    <form method="GET" action="{{ route('admin.orders.index') }}" class="toolbar-form">
        <input class="search" type="search" name="q" value="{{ $q }}" placeholder="Search order #, customer…">
        <select name="status" class="search" style="max-width: 180px;">
            <option value="">All statuses</option>
            @foreach($statuses as $s)
                <option value="{{ $s }}" @selected($status === $s)>{{ ucfirst($s) }}</option>
            @endforeach
        </select>
        <button class="btn secondary" type="submit">Filter</button>
    </form>
</div>

<div class="panel">
    <div class="panel-header">
        <h2>Order list</h2>
        <span class="muted">{{ $orders->total() }} orders</span>
    </div>
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>No</th>
                <th>Order</th>
                <th>Customer</th>
                <th>Status</th>
                <th>Total</th>
                <th>Placed</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            @forelse($orders as $order)
                <tr>
                    <td>{{ ($orders->firstItem() ?? 0) + $loop->index }}</td>
                    <td><code>{{ $order->order_number }}</code></td>
                    <td>
                        <strong>{{ $order->user?->name ?? '—' }}</strong>
                        <div class="muted">{{ $order->user?->email ?? '—' }}</div>
                    </td>
                    <td>
                        @php $st = $order->status?->value ?? (string) $order->status; @endphp
                        @if(in_array($st, ['delivered', 'paid'], true))
                            <span class="badge ok">{{ ucfirst($st) }}</span>
                        @elseif(in_array($st, ['cancelled', 'refunded'], true))
                            <span class="badge danger">{{ ucfirst($st) }}</span>
                        @elseif(in_array($st, ['pending', 'processing', 'shipped'], true))
                            <span class="badge warn">{{ ucfirst($st) }}</span>
                        @else
                            <span class="badge">{{ ucfirst($st ?: '—') }}</span>
                        @endif
                    </td>
                    <td>
                        {{ strtoupper($order->currency ?? 'USD') }}
                        {{ number_format((float) $order->total, 2) }}
                    </td>
                    <td>{{ optional($order->placed_at)->format('Y-m-d H:i') ?? '—' }}</td>
                    <td class="actions">
                        <a class="btn secondary sm" href="{{ route('admin.orders.show', $order) }}">View</a>
                    </td>
                </tr>
            @empty
                <tr><td colspan="7">No orders yet.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
    <div class="pagination">{{ $orders->links('admin.partials.pagination') }}</div>
</div>
@endsection
