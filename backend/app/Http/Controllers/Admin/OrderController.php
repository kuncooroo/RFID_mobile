<?php

namespace App\Http\Controllers\Admin;

use App\Enums\OrderStatus;
use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Support\AdminActivityLogger;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class OrderController extends Controller
{
    public function index(Request $request): View
    {
        $q = trim((string) $request->query('q', ''));
        $status = trim((string) $request->query('status', ''));

        $orders = Order::query()
            ->with(['user'])
            ->when($q !== '', function ($query) use ($q) {
                $query->where(function ($inner) use ($q) {
                    $inner->where('order_number', 'like', "%{$q}%")
                        ->orWhereHas('user', function ($user) use ($q) {
                            $user->where('name', 'like', "%{$q}%")
                                ->orWhere('email', 'like', "%{$q}%");
                        });
                });
            })
            ->when($status !== '', fn ($query) => $query->where('status', $status))
            ->orderBy('id')
            ->paginate(15)
            ->withQueryString();

        $statuses = array_map(fn (OrderStatus $s) => $s->value, OrderStatus::cases());

        return view('admin.orders.index', compact('orders', 'q', 'status', 'statuses'));
    }

    public function show(Order $order): View
    {
        $order->load(['user', 'items', 'address', 'paymentMethod', 'trackingEvents']);
        $statuses = array_map(fn (OrderStatus $s) => $s->value, OrderStatus::cases());

        return view('admin.orders.show', compact('order', 'statuses'));
    }

    public function updateStatus(Request $request, Order $order): RedirectResponse
    {
        $data = $request->validate([
            'status' => ['required', Rule::in(array_map(fn (OrderStatus $s) => $s->value, OrderStatus::cases()))],
            'courier_name' => ['nullable', 'string', 'max:120'],
            'tracking_number' => ['nullable', 'string', 'max:120'],
        ]);

        $order->status = $data['status'];
        if (array_key_exists('courier_name', $data)) {
            $order->courier_name = $data['courier_name'];
        }
        if (array_key_exists('tracking_number', $data)) {
            $order->tracking_number = $data['tracking_number'];
        }
        $order->save();

        AdminActivityLogger::log(
            'order.status_update',
            "Updated order {$order->order_number} status to {$order->status->value}",
            $order,
        );

        return redirect()
            ->route('admin.orders.show', $order)
            ->with('success', 'Order status updated successfully.');
    }
}
