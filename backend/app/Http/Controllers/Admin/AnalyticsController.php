<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\RfidVerification;
use App\Models\User;
use App\Enums\UserRole;
use Illuminate\Support\Carbon;
use Illuminate\View\View;

class AnalyticsController extends Controller
{
    public function __invoke(): View
    {
        $days = collect(range(6, 0))->map(fn (int $i) => today()->subDays($i));

        $visits = $days->map(function (Carbon $day) {
            return [
                'label' => $day->format('D d'),
                'count' => RfidVerification::query()->whereDate('created_at', $day)->count(),
            ];
        });

        $revenue = $days->map(function (Carbon $day) {
            return [
                'label' => $day->format('D d'),
                'total' => (float) Order::query()
                    ->where(function ($q) use ($day) {
                        $q->whereDate('placed_at', $day)
                            ->orWhere(function ($inner) use ($day) {
                                $inner->whereNull('placed_at')->whereDate('created_at', $day);
                            });
                    })
                    ->sum('total'),
            ];
        });

        $stats = [
            'visitors' => User::query()->where('role', UserRole::Visitor)->count(),
            'scans_7d' => RfidVerification::query()->where('created_at', '>=', now()->subDays(7))->count(),
            'revenue_7d' => (float) Order::query()->where('created_at', '>=', now()->subDays(7))->sum('total'),
            'orders_7d' => Order::query()->where('created_at', '>=', now()->subDays(7))->count(),
        ];

        return view('admin.analytics.index', compact('visits', 'revenue', 'stats'));
    }
}
