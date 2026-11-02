<?php

namespace App\Services;

use App\Models\KioskCheckIn;
use App\Models\KioskLocation;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\RfidMember;
use App\Models\WalletLedger;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class AdminReportService
{
    /** @var list<string> */
    public const TOPUP_REASONS = ['admin_topup', 'cashier_topup'];

    /** @var list<string> */
    public const PAID_STATUSES = ['paid', 'processing', 'shipped', 'delivered'];

    /**
     * @return array{0: Carbon, 1: Carbon}
     */
    public function calendarRange(int $fromDaysAgo, int $toDaysAgo = 0): array
    {
        return [
            today()->subDays($fromDaysAgo)->startOfDay(),
            today()->subDays($toDaysAgo)->endOfDay(),
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public function ticketStats(Carbon $start, Carbon $end): array
    {
        $base = KioskCheckIn::query()->whereBetween('checked_in_at', [$start, $end]);
        $granted = (clone $base)->where('status', 'success');

        $tickets = (clone $granted)->count();
        $revenue = (float) (clone $granted)->sum('amount_charged');
        $unique = (int) (clone $granted)->whereNotNull('rfid_member_id')->distinct()->count('rfid_member_id');
        $denied = (clone $base)->where('status', 'denied')->count();

        $locations = KioskLocation::query()->orderBy('name')->get();
        $grouped = (clone $granted)
            ->selectRaw('location_id, COUNT(*) as tickets, SUM(amount_charged) as revenue')
            ->groupBy('location_id')
            ->get();

        $hpp = 0.0;
        $rows = $locations->map(function (KioskLocation $location) use ($grouped, &$hpp) {
            $row = $grouped->firstWhere('location_id', $location->id);
            $count = (int) ($row->tickets ?? 0);
            $locationRevenue = (float) ($row->revenue ?? 0);
            $locationHpp = (float) $location->cost_amount * $count;
            $hpp += $locationHpp;

            return [
                'name' => $location->name,
                'tickets' => $count,
                'revenue' => $locationRevenue,
                'hpp' => $locationHpp,
                'profit' => $locationRevenue - $locationHpp,
            ];
        })->values();

        $reasons = (clone $base)
            ->where('status', 'denied')
            ->selectRaw("COALESCE(NULLIF(deny_reason, ''), 'unknown') as reason, COUNT(*) as total")
            ->groupBy('reason')
            ->orderByDesc('total')
            ->get()
            ->map(fn ($row) => [
                'reason' => (string) $row->reason,
                'label' => $this->denyLabel((string) $row->reason),
                'count' => (int) $row->total,
            ])
            ->all();

        $hours = (clone $granted)
            ->pluck('checked_in_at')
            ->countBy(fn ($at) => (int) Carbon::parse($at)->format('G'));
        $busiestHour = null;
        if ($hours->isNotEmpty()) {
            $peak = $hours->sortDesc()->keys()->first();
            $hour = (int) $peak;
            $busiestHour = [
                'label' => sprintf('%02d:00–%02d:00', $hour, ($hour + 1) % 24),
                'count' => (int) $hours[$hour],
            ];
        }

        $profit = $revenue - $hpp;

        return [
            'tickets' => $tickets,
            'denied' => $denied,
            'revenue' => $revenue,
            'hpp' => $hpp,
            'profit' => $profit,
            'margin' => $revenue > 0 ? ($profit / $revenue) * 100 : 0.0,
            'unique_cards' => $unique,
            'repeat_visits' => max(0, $tickets - $unique),
            'reasons' => $reasons,
            'locations' => $rows,
            'busiest_hour' => $busiestHour,
            'projected_revenue' => ($revenue / 7) * 30,
            'projected_profit' => ($profit / 7) * 30,
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public function shopStats(Carbon $start, Carbon $end): array
    {
        $paid = $this->ordersBetween($start, $end)->whereIn('status', self::PAID_STATUSES);
        $orders = (clone $paid)->count();
        $revenue = (float) (clone $paid)->sum('total');
        $cancelled = $this->ordersBetween($start, $end)->where('status', 'cancelled');
        $refunded = $this->ordersBetween($start, $end)->where('status', 'refunded');

        $products = OrderItem::query()
            ->join('orders', 'orders.id', '=', 'order_items.order_id')
            ->leftJoin('products', 'products.id', '=', 'order_items.product_id')
            ->whereIn('orders.status', self::PAID_STATUSES)
            ->whereRaw('COALESCE(orders.placed_at, orders.created_at) between ? and ?', [$start, $end])
            ->groupBy('order_items.name')
            ->orderByDesc('qty')
            ->limit(8)
            ->get([
                'order_items.name as name',
                DB::raw('SUM(order_items.quantity) as qty'),
                DB::raw('SUM(order_items.unit_price * order_items.quantity) as revenue'),
                DB::raw('SUM(COALESCE(order_items.cost_amount, products.cost_amount, 0) * order_items.quantity) as hpp'),
            ]);

        $lineHpp = (float) OrderItem::query()
            ->join('orders', 'orders.id', '=', 'order_items.order_id')
            ->leftJoin('products', 'products.id', '=', 'order_items.product_id')
            ->whereIn('orders.status', self::PAID_STATUSES)
            ->whereRaw('COALESCE(orders.placed_at, orders.created_at) between ? and ?', [$start, $end])
            ->selectRaw('SUM(COALESCE(order_items.cost_amount, products.cost_amount, 0) * order_items.quantity) as hpp')
            ->value('hpp');

        $profit = $revenue - $lineHpp;

        return [
            'orders' => $orders,
            'revenue' => $revenue,
            'average' => $orders > 0 ? $revenue / $orders : 0.0,
            'hpp' => $lineHpp,
            'profit' => $profit,
            'margin' => $revenue > 0 ? ($profit / $revenue) * 100 : 0.0,
            'cancelled_count' => (clone $cancelled)->count(),
            'cancelled_total' => (float) (clone $cancelled)->sum('total'),
            'refunded_count' => (clone $refunded)->count(),
            'refunded_total' => (float) (clone $refunded)->sum('total'),
            'pending_count' => $this->ordersBetween($start, $end)->where('status', 'pending')->count(),
            'products' => $products->map(fn ($row) => [
                'name' => (string) $row->name,
                'qty' => (int) $row->qty,
                'revenue' => (float) $row->revenue,
                'hpp' => (float) $row->hpp,
                'profit' => (float) $row->revenue - (float) $row->hpp,
            ])->all(),
        ];
    }

    /**
     * @return Collection<int, array{label: string, total: float}>
     */
    public function shopDaily(Carbon $start, Carbon $end): Collection
    {
        return collect(range(6, 0))->map(function (int $i) {
            $day = today()->subDays($i);
            [$from, $to] = [$day->copy()->startOfDay(), $day->copy()->endOfDay()];

            return [
                'label' => $day->format('D d'),
                'total' => (float) $this->ordersBetween($from, $to)
                    ->whereIn('status', self::PAID_STATUSES)
                    ->sum('total'),
            ];
        });
    }

    /**
     * @return array{topup: float, gate: float, shop: float}
     */
    public function moneyStats(Carbon $start, Carbon $end): array
    {
        $ledger = WalletLedger::query()->whereBetween('created_at', [$start, $end]);

        return [
            'topup' => (float) (clone $ledger)->whereIn('reason', self::TOPUP_REASONS)->sum('delta'),
            'gate' => abs((float) (clone $ledger)->where('reason', 'gate_debit')->sum('delta')),
            'shop' => (float) $this->ordersBetween($start, $end)->whereIn('status', self::PAID_STATUSES)->sum('total'),
        ];
    }

    /**
     * @return array<string, float>
     */
    public function balanceCheck(): array
    {
        $activeIds = RfidMember::query()->where('is_active', true)->pluck('id');
        $activeBalance = (float) RfidMember::query()->where('is_active', true)->sum('balance');

        $ledger = WalletLedger::query()->where(function ($query) use ($activeIds) {
            $query->whereIn('rfid_member_id', $activeIds)->orWhereNull('rfid_member_id');
        });

        $topup = (float) (clone $ledger)->whereIn('reason', self::TOPUP_REASONS)->sum('delta');
        $gateSigned = (float) (clone $ledger)->where('reason', 'gate_debit')->sum('delta');
        $book = (float) (clone $ledger)->sum('delta');
        $gate = abs($gateSigned);
        $adjustment = $book - $topup - $gateSigned;

        $ticketRevenue = (float) KioskCheckIn::query()->where('status', 'success')->sum('amount_charged');
        $gateAll = abs((float) WalletLedger::query()->where('reason', 'gate_debit')->sum('delta'));

        return [
            'active_balance' => $activeBalance,
            'topup' => $topup,
            'gate' => $gate,
            'adjustment' => $adjustment,
            'book' => $book,
            'balance_gap' => $activeBalance - $book,
            'ticket_revenue' => $ticketRevenue,
            'gate_ledger' => $gateAll,
            'ticket_gap' => $ticketRevenue - $gateAll,
        ];
    }

    /**
     * @param  array<string, float|int>  $current
     * @param  array<string, float|int>  $previous
     * @return array<string, array{diff: float, percent: ?float}>
     */
    public function compare(array $current, array $previous, array $keys): array
    {
        $out = [];
        foreach ($keys as $key) {
            $now = (float) ($current[$key] ?? 0);
            $then = (float) ($previous[$key] ?? 0);
            $out[$key] = [
                'diff' => $now - $then,
                'percent' => abs($then) < 0.00001 ? null : (($now - $then) / $then) * 100,
            ];
        }

        return $out;
    }

    public function denyLabel(string $reason): string
    {
        return match ($reason) {
            'insufficient_balance' => 'Saldo tidak cukup',
            'unknown' => 'Tidak tercatat',
            default => str_replace('_', ' ', $reason),
        };
    }

    private function ordersBetween(Carbon $start, Carbon $end)
    {
        return Order::query()->whereRaw(
            'COALESCE(placed_at, created_at) between ? and ?',
            [$start, $end],
        );
    }
}
