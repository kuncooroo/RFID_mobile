<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\CashierShift;
use App\Models\KioskCheckIn;
use App\Models\KioskLocation;
use App\Models\KioskPresence;
use App\Models\RfidMember;
use App\Models\UserExperience;
use App\Models\WalletLedger;
use App\Services\AdminReportService;
use Illuminate\View\View;

class DashboardController extends Controller
{
    public function __invoke(AdminReportService $reports): View
    {
        $admin = auth('admin')->user();
        $showFinance = (bool) ($admin?->allows('analytics.view') || $admin?->allows('finance.manage'));
        $showOps = (bool) ($admin?->allows('visitors.manage') || $admin?->allows('rfid.manage'));
        $showExperiences = (bool) $admin?->allows('experiences.manage');
        $showCashier = (bool) $admin?->allows('cashier.manage');
        $showBooks = (bool) $admin?->allows('finance.manage');

        $locations = KioskLocation::query()->where('is_active', true)->orderBy('id')->get();
        $fare = (float) ($locations->first()?->fare_amount ?? 0);

        $grantedToday = KioskCheckIn::query()
            ->where('status', 'success')
            ->whereDate('checked_in_at', today())
            ->count();
        $deniedToday = KioskCheckIn::query()
            ->where('status', 'denied')
            ->whereDate('checked_in_at', today())
            ->count();

        $grouped = KioskCheckIn::query()
            ->selectRaw('location_id, COUNT(*) as tickets, SUM(amount_charged) as revenue')
            ->where('status', 'success')
            ->whereDate('checked_in_at', today())
            ->groupBy('location_id')
            ->get();

        $revenue = (float) $grouped->sum('revenue');
        $hpp = 0.0;
        foreach ($grouped as $row) {
            $cost = (float) ($locations->firstWhere('id', $row->location_id)?->cost_amount ?? 0);
            $hpp += $cost * (int) $row->tickets;
        }
        $profit = $revenue - $hpp;
        $margin = $revenue > 0 ? ($profit / $revenue) * 100 : 0.0;

        $unboundCards = RfidMember::query()
            ->whereNull('user_id')
            ->where('is_active', true)
            ->count();

        $lowCards = RfidMember::query()
            ->where('is_active', true)
            ->when($fare > 0, fn ($query) => $query->where('balance', '<', $fare * 2))
            ->with('user')
            ->orderBy('balance')
            ->limit(8)
            ->get();

        $recentTaps = KioskCheckIn::query()
            ->with(['user', 'rfidMember', 'location'])
            ->orderByDesc('checked_in_at')
            ->orderByDesc('id')
            ->limit(8)
            ->get();

        $recentExperiences = UserExperience::query()
            ->with('user')
            ->latest()
            ->limit(6)
            ->get();

        $recentCaptures = KioskPresence::query()
            ->with('user')
            ->whereNotNull('photo_path')
            ->orderByDesc('captured_at')
            ->limit(6)
            ->get();

        $todayMoney = $reports->moneyStats(today()->startOfDay(), today()->endOfDay());
        $balance = $showBooks ? $reports->balanceCheck() : null;
        $openShift = $showCashier
            ? CashierShift::query()
                ->where('admin_id', $admin?->id)
                ->where('status', 'open')
                ->latest('opened_at')
                ->first()
            : null;
        $shiftTopup = $openShift
            ? (float) WalletLedger::query()
                ->where('shift_id', $openShift->id)
                ->where('reason', 'cashier_topup')
                ->sum('delta')
            : 0.0;

        return view('admin.dashboard', compact(
            'showFinance',
            'showOps',
            'showExperiences',
            'showCashier',
            'showBooks',
            'todayMoney',
            'balance',
            'openShift',
            'shiftTopup',
            'locations',
            'fare',
            'grantedToday',
            'deniedToday',
            'revenue',
            'hpp',
            'profit',
            'margin',
            'unboundCards',
            'lowCards',
            'recentTaps',
            'recentExperiences',
            'recentCaptures',
        ));
    }
}
