<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\KioskCheckIn;
use App\Models\KioskLocation;
use App\Services\AdminReportService;
use App\Support\AdminActivityLogger;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\View\View;

class AnalyticsController extends Controller
{
    public function index(AdminReportService $reports): View
    {
        [$start, $end] = $reports->calendarRange(6);
        [$prevStart, $prevEnd] = $reports->calendarRange(13, 7);

        $ticket = $reports->ticketStats($start, $end);
        $previousTicket = $reports->ticketStats($prevStart, $prevEnd);
        $ticketCompare = $reports->compare($ticket, $previousTicket, [
            'tickets', 'denied', 'revenue', 'profit', 'unique_cards', 'repeat_visits',
        ]);

        $shop = $reports->shopStats($start, $end);
        $previousShop = $reports->shopStats($prevStart, $prevEnd);
        $shopCompare = $reports->compare($shop, $previousShop, ['orders', 'revenue', 'average', 'profit']);

        $combined = [
            'revenue' => $ticket['revenue'] + $shop['revenue'],
            'profit' => $ticket['profit'] + $shop['profit'],
        ];
        $combined['margin'] = $combined['revenue'] > 0
            ? ($combined['profit'] / $combined['revenue']) * 100
            : 0.0;
        $previousCombined = [
            'revenue' => $previousTicket['revenue'] + $previousShop['revenue'],
            'profit' => $previousTicket['profit'] + $previousShop['profit'],
        ];
        $combinedCompare = $reports->compare($combined, $previousCombined, ['revenue', 'profit']);

        $days = collect(range(6, 0))->map(fn (int $i) => today()->subDays($i));
        $visits = $days->map(fn (Carbon $day) => [
            'label' => $day->format('D d'),
            'count' => KioskCheckIn::query()
                ->where('status', 'success')
                ->whereDate('checked_in_at', $day)
                ->count(),
        ]);
        $revenue = $days->map(fn (Carbon $day) => [
            'label' => $day->format('D d'),
            'total' => (float) KioskCheckIn::query()
                ->where('status', 'success')
                ->whereDate('checked_in_at', $day)
                ->sum('amount_charged'),
        ]);

        return view('admin.analytics.index', [
            'ticket' => $ticket,
            'ticketCompare' => $ticketCompare,
            'shop' => $shop,
            'shopCompare' => $shopCompare,
            'combined' => $combined,
            'combinedCompare' => $combinedCompare,
            'visits' => $visits,
            'revenue' => $revenue,
            'shopDaily' => $reports->shopDaily($start, $end),
            'locations' => KioskLocation::query()->orderBy('name')->get(),
        ]);
    }

    public function updateCosts(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'costs' => ['required', 'array'],
            'costs.*' => ['numeric', 'min:0', 'max:100000000'],
        ]);

        foreach ($data['costs'] as $id => $cost) {
            KioskLocation::query()->whereKey($id)->update([
                'cost_amount' => number_format((float) $cost, 2, '.', ''),
            ]);
        }

        AdminActivityLogger::log('analytics.costs', 'Updated ticket HPP');

        return back()->with('success', 'HPP tiket disimpan.');
    }
}
