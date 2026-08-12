<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\Member;
use App\Models\User;
use App\Models\UserSetting;
use App\Support\AdminActivityLogger;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class VisitorController extends Controller
{
    public function index(Request $request): View
    {
        $q = trim((string) $request->query('q', ''));

        $visitors = User::query()
            ->where('role', UserRole::Visitor)
            ->with(['rfidMember', 'member'])
            ->when($q !== '', function ($query) use ($q) {
                $query->where(function ($inner) use ($q) {
                    $inner->where('name', 'like', "%{$q}%")
                        ->orWhere('email', 'like', "%{$q}%")
                        ->orWhere('phone', 'like', "%{$q}%")
                        ->orWhereHas('rfidMember', fn ($r) => $r->where('rfid_uid', 'like', "%{$q}%")
                            ->orWhere('member_code', 'like', "%{$q}%"));
                });
            })
            ->latest()
            ->paginate(15)
            ->withQueryString();

        return view('admin.visitors.index', compact('visitors', 'q'));
    }

    public function create(): View
    {
        return view('admin.visitors.create');
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => ['nullable', 'email', 'max:190', 'unique:users,email'],
            'phone' => ['nullable', 'string', 'max:40', 'unique:users,phone'],
            'password' => ['required', 'string', 'min:8'],
        ]);

        if (empty($data['email']) && empty($data['phone'])) {
            return back()->withInput()->withErrors([
                'email' => 'Provide at least an email or phone.',
            ]);
        }

        $user = DB::transaction(function () use ($data) {
            $user = User::query()->create([
                'name' => $data['name'],
                'email' => $data['email'] ?? null,
                'phone' => $data['phone'] ?? null,
                'password' => Hash::make($data['password']),
                'role' => UserRole::Visitor,
                'onboarding_completed_at' => now(),
            ]);

            Member::query()->create([
                'user_id' => $user->id,
                'display_name' => $user->name,
                'membership_tier' => 'standard',
            ]);

            UserSetting::query()->create(['user_id' => $user->id]);
            Cart::query()->create(['user_id' => $user->id, 'currency' => 'USD']);

            return $user;
        });

        AdminActivityLogger::log('visitor.create', "Created visitor #{$user->id} {$user->name}", $user);

        return redirect()
            ->route('admin.visitors.index')
            ->with('success', 'Visitor created successfully.');
    }

    public function edit(User $visitor): View
    {
        abort_unless($visitor->role === UserRole::Visitor, 404);
        $visitor->load('rfidMember');

        return view('admin.visitors.edit', compact('visitor'));
    }

    public function update(Request $request, User $visitor): RedirectResponse
    {
        abort_unless($visitor->role === UserRole::Visitor, 404);

        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => ['nullable', 'email', 'max:190', Rule::unique('users', 'email')->ignore($visitor->id)],
            'phone' => ['nullable', 'string', 'max:40', Rule::unique('users', 'phone')->ignore($visitor->id)],
            'password' => ['nullable', 'string', 'min:8'],
        ]);

        $visitor->fill([
            'name' => $data['name'],
            'email' => $data['email'] ?? null,
            'phone' => $data['phone'] ?? null,
        ]);

        if (! empty($data['password'])) {
            $visitor->password = Hash::make($data['password']);
        }

        $visitor->save();

        AdminActivityLogger::log('visitor.update', "Updated visitor #{$visitor->id} {$visitor->name}", $visitor);

        return redirect()
            ->route('admin.visitors.index')
            ->with('success', 'Visitor updated successfully.');
    }

    public function destroy(User $visitor): RedirectResponse
    {
        abort_unless($visitor->role === UserRole::Visitor, 404);

        $label = "#{$visitor->id} {$visitor->name}";
        $visitor->delete();

        AdminActivityLogger::log('visitor.delete', "Deleted visitor {$label}");

        return redirect()
            ->route('admin.visitors.index')
            ->with('success', 'Visitor deleted successfully.');
    }
}
