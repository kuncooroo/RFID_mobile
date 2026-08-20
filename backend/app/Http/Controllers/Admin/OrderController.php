<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\View\View;

/**
 * Skeleton Store → Orders admin surface.
 * Status updates / detail pages can be added later.
 */
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
            ->latest('placed_at')
            ->latest('id')
            ->paginate(15)
            ->withQueryString();

        return view('admin.orders.index', compact('orders', 'q', 'status'));
    }
}
