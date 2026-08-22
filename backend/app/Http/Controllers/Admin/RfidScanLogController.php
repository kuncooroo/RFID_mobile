<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\KioskCheckIn;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\View\View;

class RfidScanLogController extends Controller
{
    public function index(Request $request): View
    {
        $status = trim((string) $request->query('status', ''));
        $q = trim((string) $request->query('q', ''));
        $preset = trim((string) $request->query('preset', ''));

        [$dateFrom, $dateTo] = $this->resolveDateRange($request, $preset);

        $scans = KioskCheckIn::query()
            ->with(['user', 'rfidMember', 'location'])
            ->when($status !== '', fn ($query) => $query->where('status', $status))
            ->when($q !== '', function ($query) use ($q) {
                $query->where(function ($inner) use ($q) {
                    $inner->whereHas('user', function ($user) use ($q) {
                        $user->where('name', 'like', "%{$q}%")
                            ->orWhere('email', 'like', "%{$q}%");
                    })->orWhereHas('rfidMember', function ($rfid) use ($q) {
                        $rfid->where('rfid_uid', 'like', "%{$q}%")
                            ->orWhere('member_code', 'like', "%{$q}%");
                    });
                });
            })
            ->when($dateFrom !== null, function ($query) use ($dateFrom) {
                $query->where('checked_in_at', '>=', $dateFrom->copy()->startOfDay());
            })
            ->when($dateTo !== null, function ($query) use ($dateTo) {
                $query->where('checked_in_at', '<=', $dateTo->copy()->endOfDay());
            })
            ->orderByDesc('checked_in_at')
            ->orderByDesc('id')
            ->paginate(20)
            ->withQueryString();

        return view('admin.rfid.scans', [
            'scans' => $scans,
            'status' => $status,
            'q' => $q,
            'preset' => $preset,
            'dateFrom' => $dateFrom?->toDateString(),
            'dateTo' => $dateTo?->toDateString(),
        ]);
    }

    /**
     * @return array{0: ?Carbon, 1: ?Carbon}
     */
    private function resolveDateRange(Request $request, string $preset): array
    {
        $today = now()->startOfDay();

        if ($preset !== '') {
            return match ($preset) {
                'today' => [$today->copy(), $today->copy()],
                '7d' => [$today->copy()->subDays(6), $today->copy()],
                '30d' => [$today->copy()->subDays(29), $today->copy()],
                'month' => [$today->copy()->startOfMonth(), $today->copy()],
                default => $this->parseCustomDates($request),
            };
        }

        return $this->parseCustomDates($request);
    }

    /**
     * @return array{0: ?Carbon, 1: ?Carbon}
     */
    private function parseCustomDates(Request $request): array
    {
        $fromRaw = trim((string) $request->query('date_from', ''));
        $toRaw = trim((string) $request->query('date_to', ''));

        $from = null;
        $to = null;

        try {
            if ($fromRaw !== '') {
                $from = Carbon::createFromFormat('Y-m-d', $fromRaw)->startOfDay();
            }
        } catch (\Throwable) {
            $from = null;
        }

        try {
            if ($toRaw !== '') {
                $to = Carbon::createFromFormat('Y-m-d', $toRaw)->startOfDay();
            }
        } catch (\Throwable) {
            $to = null;
        }

        if ($from && $to && $from->gt($to)) {
            [$from, $to] = [$to, $from];
        }

        return [$from, $to];
    }
}
