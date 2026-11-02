<?php

namespace App\Services;

use App\Exceptions\DomainException;
use App\Models\KioskPointLedger;
use App\Models\Member;
use App\Models\RfidMember;
use App\Models\User;
use App\Models\WalletLedger;
use Illuminate\Support\Facades\DB;

class WalletService
{
    public function topUp(
        User $user,
        float $amount,
        string $reason = 'admin_topup',
        ?int $adminId = null,
        ?int $shiftId = null,
    ): Member {
        $card = RfidMember::query()
            ->where('user_id', $user->id)
            ->where('is_active', true)
            ->first();
        if (! $card) {
            throw new DomainException(
                'Pengunjung ini belum punya kartu. Saldo diisi ke kartu yang sudah jadi.',
                422,
                'wallet_card_missing',
            );
        }

        $member = Member::query()->where('user_id', $user->id)->first();
        if (! $member) {
            throw new DomainException('Profil member tidak ditemukan.', 422, 'member_missing');
        }

        $this->topUpCard($card, $amount, $reason, $adminId, $shiftId);

        return $member->refresh();
    }

    public function topUpCard(
        RfidMember $card,
        float $amount,
        string $reason = 'cashier_topup',
        ?int $adminId = null,
        ?int $shiftId = null,
    ): RfidMember {
        if ($amount <= 0) {
            throw new DomainException('Nominal top-up harus lebih dari 0.', 422, 'wallet_amount_invalid');
        }

        return DB::transaction(function () use ($card, $amount, $reason, $adminId, $shiftId) {
            $locked = RfidMember::query()->whereKey($card->id)->lockForUpdate()->first();
            if (! $locked || ! $locked->is_active) {
                throw new DomainException('Kartu tidak aktif.', 422, 'wallet_card_inactive');
            }

            $cap = $locked->user_id
                ? (float) config('kiosk.registered_balance_cap', 10000000)
                : (float) config('kiosk.anonymous_balance_cap', 1000000);
            $next = (float) $locked->balance + $amount;
            if ((int) round($next * 100) > (int) round($cap * 100)) {
                $label = $locked->user_id ? 'terdaftar' : 'tanpa identitas';
                throw new DomainException(
                    'Saldo kartu '.$label.' tidak boleh melebihi '.number_format($cap, 0, ',', '.').'.',
                    422,
                    'wallet_balance_cap',
                );
            }

            $locked->balance = $this->money($next);
            $locked->save();

            if ($locked->user_id) {
                $member = Member::query()->where('user_id', $locked->user_id)->lockForUpdate()->first();
                if ($member) {
                    $member->balance = $locked->balance;
                    $member->save();
                }
            }

            WalletLedger::query()->create([
                'user_id' => $locked->user_id,
                'rfid_member_id' => $locked->id,
                'admin_id' => $adminId,
                'shift_id' => $shiftId,
                'delta' => $this->money($amount),
                'balance_after' => $locked->balance,
                'reason' => $reason,
            ]);

            return $locked->refresh();
        });
    }

    /**
     * Convert points into checkout discount credit.
     * Rate comes from config kiosk.points_per_currency (points needed for 1.00 currency).
     */
    public function redeemPoints(User $user, int $points): Member
    {
        $rate = max(1, (int) config('kiosk.points_per_currency', 100));
        if ($points < $rate || $points % $rate !== 0) {
            throw new DomainException(
                "Poin ditukar kelipatan {$rate}.",
                422,
                'points_redeem_invalid',
            );
        }

        return DB::transaction(function () use ($user, $points, $rate) {
            $member = $this->lockMember($user);
            if ((int) $member->points < $points) {
                throw new DomainException('Poin tidak cukup.', 422, 'points_insufficient');
            }

            $credit = round($points / $rate, 2);
            $member->points = (int) $member->points - $points;
            $member->discount_credit = $this->money((float) $member->discount_credit + $credit);
            $member->save();

            KioskPointLedger::query()->create([
                'user_id' => $user->id,
                'check_in_id' => null,
                'delta' => -$points,
                'balance_after' => (int) $member->points,
                'reason' => 'redeem_discount',
            ]);

            return $member->refresh();
        });
    }

    /**
     * Apply stored discount credit to an order total. Caller must already be inside a transaction.
     */
    public function consumeDiscountCredit(User $user, float $payable): float
    {
        if ($payable <= 0) {
            return 0.0;
        }

        $member = Member::query()->where('user_id', $user->id)->lockForUpdate()->first();
        if (! $member) {
            return 0.0;
        }

        $available = (float) $member->discount_credit;
        $discount = min($available, $payable);
        if ($discount <= 0) {
            return 0.0;
        }

        $member->discount_credit = $this->money($available - $discount);
        $member->save();

        return round($discount, 2);
    }

    private function lockMember(User $user): Member
    {
        $member = Member::query()->where('user_id', $user->id)->lockForUpdate()->first();
        if (! $member) {
            throw new DomainException('Profil member tidak ditemukan.', 422, 'member_missing');
        }

        return $member;
    }

    private function money(float $value): string
    {
        return number_format($value, 2, '.', '');
    }
}
