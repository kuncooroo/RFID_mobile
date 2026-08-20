<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\RfidMember;
use App\Models\RfidVerification;
use App\Models\User;
use Illuminate\View\View;

class DashboardController extends Controller
{
    public function __invoke(): View
    {
        $visitorCount = User::query()->where('role', UserRole::Visitor)->count();
        $boundCards = RfidMember::query()->whereNotNull('user_id')->where('is_active', true)->count();
        $unboundCards = RfidMember::query()->whereNull('user_id')->where('is_active', true)->count();
        $scanToday = RfidVerification::query()->whereDate('created_at', today())->count();
        $revenueToday = (float) Order::query()
            ->where(function ($q) {
                $q->whereDate('placed_at', today())
                    ->orWhere(function ($inner) {
                        $inner->whereNull('placed_at')->whereDate('created_at', today());
                    });
            })
            ->sum('total');

        $visitors = User::query()
            ->where('role', UserRole::Visitor)
            ->with(['rfidMember', 'member'])
            ->orderBy('id')
            ->paginate(12);

        $recentScans = RfidVerification::query()
            ->with(['user', 'rfidMember'])
            ->orderBy('id')
            ->limit(8)
            ->get();

        return view('admin.dashboard', compact(
            'visitorCount',
            'boundCards',
            'unboundCards',
            'scanToday',
            'revenueToday',
            'visitors',
            'recentScans',
        ));
    }
}
