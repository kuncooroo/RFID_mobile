<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\RfidMember;
use App\Models\User;
use App\Support\AdminActivityLogger;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class RfidBindController extends Controller
{
    public function create(Request $request): View
    {
        $visitors = User::query()
            ->where('role', UserRole::Visitor)
            ->with('rfidMember')
            ->orderBy('name')
            ->get();

        $selectedUserId = $request->integer('user_id') ?: null;

        return view('admin.rfid.bind', compact('visitors', 'selectedUserId'));
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'user_id' => [
                'required',
                'integer',
                Rule::exists('users', 'id')->where(fn ($q) => $q->where('role', UserRole::Visitor->value)),
            ],
            'rfid_uid' => ['required', 'string', 'max:100'],
            'member_code' => ['nullable', 'string', 'max:100'],
            'is_active' => ['sometimes', 'boolean'],
        ]);

        $rfidUid = trim($data['rfid_uid']);
        $memberCode = trim((string) ($data['member_code'] ?? '')) ?: 'MEM-'.Str::upper(Str::random(6));
        $isActive = $request->boolean('is_active', true);

        $conflict = RfidMember::query()
            ->where(function ($q) use ($rfidUid, $memberCode) {
                $q->where('rfid_uid', $rfidUid)->orWhere('member_code', $memberCode);
            })
            ->where(function ($q) use ($data) {
                $q->whereNull('user_id')->orWhere('user_id', '!=', $data['user_id']);
            })
            ->first();

        if ($conflict !== null && (int) $conflict->user_id !== (int) $data['user_id']) {
            if ($conflict->user_id !== null) {
                return back()->withInput()->withErrors([
                    'rfid_uid' => 'This RFID UID / member code is already bound to another visitor.',
                ]);
            }
        }

        $user = User::query()->findOrFail($data['user_id']);

        DB::transaction(function () use ($user, $rfidUid, $memberCode, $isActive, $conflict) {
            // Unbind previous card on this user (keep row unbound for reuse).
            $existing = $user->rfidMember;
            if ($existing !== null && $existing->rfid_uid !== $rfidUid) {
                $existing->update(['user_id' => null, 'is_active' => false]);
            }

            if ($conflict !== null && $conflict->user_id === null) {
                $conflict->update([
                    'user_id' => $user->id,
                    'rfid_uid' => $rfidUid,
                    'member_code' => $memberCode,
                    'card_number' => $conflict->card_number ?: RfidMember::generateCardNumber(),
                    'is_active' => $isActive,
                ]);

                return;
            }

            RfidMember::query()->updateOrCreate(
                ['user_id' => $user->id],
                [
                    'rfid_uid' => $rfidUid,
                    'member_code' => $memberCode,
                    'card_number' => $user->rfidMember?->card_number ?: RfidMember::generateCardNumber(),
                    'is_active' => $isActive,
                ],
            );
        });

        $user->load('rfidMember');

        AdminActivityLogger::log(
            'rfid.bind',
            "Bound RFID {$rfidUid} to visitor #{$user->id} {$user->name}",
            $user->rfidMember,
        );

        $number = $user->rfidMember?->card_number;

        return redirect()
            ->route('admin.visitors.show', $user)
            ->with('success', "Kartu {$rfidUid} terhubung ke {$user->name}. Nomor kartu: {$number}");
    }

    public function stock(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'rfid_uid' => ['required', 'string', 'max:100'],
        ]);

        $rfidUid = trim($data['rfid_uid']);
        $card = RfidMember::query()->where('rfid_uid', $rfidUid)->first();

        if ($card !== null && $card->user_id !== null) {
            return back()->withInput()->withErrors([
                'stock_rfid_uid' => 'Kartu ini sudah terhubung ke pengunjung.',
            ]);
        }

        if ($card === null) {
            $card = RfidMember::query()->create([
                'user_id' => null,
                'member_code' => 'STK-'.Str::upper(Str::random(6)),
                'rfid_uid' => $rfidUid,
                'is_active' => true,
                'balance' => 0,
            ]);
        } elseif (! $card->is_active || $card->card_number === null) {
            $card->update([
                'is_active' => true,
                'card_number' => $card->card_number ?: RfidMember::generateCardNumber(),
            ]);
        }

        AdminActivityLogger::log(
            'rfid.stock',
            "Stocked RFID {$rfidUid} as {$card->card_number}",
            $card,
        );

        return redirect()
            ->route('admin.rfid.bind')
            ->with('success', "Kartu stok {$rfidUid} siap. Nomor 16 digit: {$card->card_number}. Hubungkan lewat aplikasi atau daftar sendiri di kiosk.");
    }
}
