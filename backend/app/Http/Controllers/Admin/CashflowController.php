<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\WalletLedger;
use App\Services\AdminReportService;
use Illuminate\Http\Request;
use Illuminate\View\View;

class CashflowController extends Controller
{
    public function index(Request $request, AdminReportService $reports): View
    {
        $admin = auth('admin')->user();
        abort_unless($admin?->allows('finance.manage'), 403, 'Anda tidak punya izin untuk halaman ini.');

        [$start] = $reports->calendarRange(6);
        $today = [today()->startOfDay(), today()->endOfDay()];
        $week = [$start, today()->endOfDay()];

        $reason = trim((string) $request->query('reason', ''));
        $ledgers = WalletLedger::query()
            ->with(['user', 'rfidMember', 'admin'])
            ->when($reason !== '', fn ($query) => $query->where('reason', $reason))
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->paginate(20)
            ->withQueryString();

        return view('admin.cashflow.index', [
            'today' => $reports->moneyStats($today[0], $today[1]),
            'week' => $reports->moneyStats($week[0], $week[1]),
            'check' => $reports->balanceCheck(),
            'ledgers' => $ledgers,
            'reason' => $reason,
        ]);
    }
}
