<?php

namespace App\Http\Controllers\Admin;

use App\Exceptions\DomainException;
use App\Http\Controllers\Controller;
use App\Models\CashierShift;
use App\Models\RfidMember;
use App\Models\WalletLedger;
use App\Services\WalletService;
use App\Support\AdminActivityLogger;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class CashierController extends Controller
{
    public function index(): View
    {
        $admin = auth('admin')->user();
        abort_unless(
            $admin?->allows('cashier.manage') || $admin?->allows('finance.manage'),
            403,
            'Anda tidak punya izin untuk halaman ini.',
        );

        $open = CashierShift::query()
            ->where('admin_id', $admin->id)
            ->where('status', 'open')
            ->latest('opened_at')
            ->first();

        $movements = $open
            ? WalletLedger::query()
                ->with(['user', 'rfidMember'])
                ->where('shift_id', $open->id)
                ->orderByDesc('id')
                ->get()
            : collect();

        $shifts = CashierShift::query()
            ->with('admin')
            ->when(! $admin->allows('finance.manage'), fn ($query) => $query->where('admin_id', $admin->id))
            ->latest('opened_at')
            ->limit(20)
            ->get();

        return view('admin.cashier.index', [
            'canOperate' => $admin->allows('cashier.manage'),
            'openShift' => $open,
            'shiftCash' => $this->expectedCash($open),
            'movements' => $movements,
            'shifts' => $shifts->map(fn (CashierShift $shift) => [
                'model' => $shift,
                'expected' => $this->expectedCash($shift),
            ]),
        ]);
    }

    public function open(Request $request): RedirectResponse
    {
        $admin = $this->operator();
        $data = $request->validate([
            'opening_float' => ['required', 'numeric', 'min:0', 'max:100000000'],
        ]);

        $exists = CashierShift::query()
            ->where('admin_id', $admin->id)
            ->where('status', 'open')
            ->exists();
        if ($exists) {
            return back()->with('error', 'Masih ada shift yang terbuka.');
        }

        $shift = CashierShift::query()->create([
            'admin_id' => $admin->id,
            'status' => 'open',
            'opening_float' => $data['opening_float'],
            'opened_at' => now(),
        ]);

        AdminActivityLogger::log('cashier.open', 'Opened cashier shift #'.$shift->id, $shift);

        return back()->with('success', 'Shift kasir dibuka.');
    }

    public function topUp(Request $request, WalletService $wallet): RedirectResponse
    {
        $admin = $this->operator();
        $data = $request->validate([
            'card' => ['required', 'string', 'max:64'],
            'amount' => ['required', 'numeric', 'min:0.01', 'max:100000000'],
        ]);

        $shift = CashierShift::query()
            ->where('admin_id', $admin->id)
            ->where('status', 'open')
            ->first();
        if (! $shift) {
            return back()->with('error', 'Buka shift dulu sebelum menerima uang tunai.')->withInput();
        }

        $code = trim($data['card']);
        $card = RfidMember::query()
            ->where('is_active', true)
            ->where(function ($query) use ($code) {
                $query->where('rfid_uid', $code)
                    ->orWhere('card_number', $code)
                    ->orWhere('member_code', $code);
            })
            ->first();
        if (! $card) {
            return back()->with('error', 'Kartu tidak ditemukan. Kartu harus sudah diterbitkan.')->withInput();
        }

        try {
            $updated = $wallet->topUpCard($card, (float) $data['amount'], 'cashier_topup', $admin->id, $shift->id);
        } catch (DomainException $e) {
            return back()->with('error', $e->getMessage())->withInput();
        }

        AdminActivityLogger::log(
            'cashier.topup',
            'Cash top up card #'.$updated->id.' by '.$data['amount'].' on shift #'.$shift->id,
            $updated,
        );

        return back()->with('success', 'Saldo kartu bertambah. Saldo sekarang '.number_format((float) $updated->balance, 0, ',', '.').'.');
    }

    public function close(Request $request, CashierShift $shift): RedirectResponse
    {
        $admin = $this->operator();
        abort_unless($shift->admin_id === $admin->id || $admin->isSuperadmin(), 403);

        $data = $request->validate([
            'cash_counted' => ['required', 'numeric', 'min:0', 'max:100000000'],
            'note' => ['nullable', 'string', 'max:500'],
        ]);

        if (! $shift->isOpen()) {
            return back()->with('error', 'Shift ini sudah ditutup.');
        }

        $shift->update([
            'status' => 'closed',
            'closed_at' => now(),
            'cash_counted' => $data['cash_counted'],
            'note' => $data['note'] ?? null,
        ]);

        AdminActivityLogger::log('cashier.close', 'Closed cashier shift #'.$shift->id, $shift);

        return back()->with('success', 'Shift ditutup. Selisih kas tercatat.');
    }

    private function operator()
    {
        $admin = auth('admin')->user();
        abort_unless($admin?->allows('cashier.manage'), 403, 'Anda tidak punya izin untuk halaman ini.');

        return $admin;
    }

    private function expectedCash(?CashierShift $shift): float
    {
        if (! $shift) {
            return 0.0;
        }

        $topup = (float) WalletLedger::query()
            ->where('shift_id', $shift->id)
            ->where('reason', 'cashier_topup')
            ->sum('delta');

        return (float) $shift->opening_float + $topup;
    }
}
