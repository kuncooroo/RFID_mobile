@extends('admin.layouts.app')

@section('title', 'Order '.$order->order_number)
@section('heading', 'Order '.$order->order_number)
@section('subheading', 'Customer: '.($order->user?->name ?? '—'))

@section('content')
<div class="panel">
    <div class="panel-header">
        <h2>Order details</h2>
        <a class="btn secondary sm" href="{{ route('admin.orders.index') }}">Back</a>
    </div>

    <div class="form-grid" style="margin-bottom: 24px;">
        <div>
            <div class="muted">Customer</div>
            <strong>{{ $order->user?->name ?? '—' }}</strong>
            <div class="muted">{{ $order->user?->email ?? '—' }}</div>
        </div>
        <div>
            <div class="muted">Placed</div>
            <strong>{{ optional($order->placed_at)->format('Y-m-d H:i') ?? '—' }}</strong>
        </div>
        <div>
            <div class="muted">Total</div>
            <strong>{{ strtoupper($order->currency ?? 'USD') }} {{ number_format((float) $order->total, 2) }}</strong>
            <div class="muted">
                Subtotal {{ number_format((float) $order->subtotal, 2) }}
                · Shipping {{ number_format((float) $order->shipping_fee, 2) }}
                · Discount {{ number_format((float) $order->discount, 2) }}
            </div>
        </div>
        <div>
            <div class="muted">Courier / Tracking</div>
            <strong>{{ $order->courier_name ?: '—' }}</strong>
            <div class="muted">{{ $order->tracking_number ?: '—' }}</div>
        </div>
    </div>

    <form method="POST" action="{{ route('admin.orders.updateStatus', $order) }}" class="form-grid">
        @csrf
        @method('PUT')
        <label>
            Status
            <select name="status" required>
                @foreach($statuses as $s)
                    <option value="{{ $s }}" @selected(old('status', $order->status?->value) === $s)>{{ ucfirst($s) }}</option>
                @endforeach
            </select>
        </label>
        <label>
            Courier name
            <input type="text" name="courier_name" value="{{ old('courier_name', $order->courier_name) }}">
        </label>
        <label>
            Tracking number
            <input type="text" name="tracking_number" value="{{ old('tracking_number', $order->tracking_number) }}">
        </label>
        <div class="full actions">
            <button class="btn" type="submit">Update status</button>
        </div>
    </form>
</div>

<div class="panel">
    <div class="panel-header">
        <h2>Items</h2>
    </div>
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>#</th>
                <th>Item</th>
                <th>Qty</th>
                <th>Unit price</th>
                <th>Line total</th>
            </tr>
            </thead>
            <tbody>
            @forelse($order->items as $item)
                <tr>
                    <td>{{ $loop->iteration }}</td>
                    <td>
                        <strong>{{ $item->name }}</strong>
                        <div class="muted">{{ $item->variant_label ?? '—' }}</div>
                    </td>
                    <td>{{ $item->quantity }}</td>
                    <td>{{ number_format((float) $item->unit_price, 2) }}</td>
                    <td>{{ number_format((float) $item->unit_price * (int) $item->quantity, 2) }}</td>
                </tr>
            @empty
                <tr><td colspan="5">No items on this order.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection
