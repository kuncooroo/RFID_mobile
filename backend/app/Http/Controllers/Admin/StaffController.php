<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\User;
use App\Support\AdminActivityLogger;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class StaffController extends Controller
{
    public function index(): View
    {
        $staff = User::query()
            ->whereIn('role', UserRole::staffValues())
            ->orderByRaw("FIELD(role, 'superadmin', 'admin')")
            ->orderBy('name')
            ->paginate(20);

        return view('admin.staff.index', compact('staff'));
    }

    public function create(): View
    {
        return view('admin.staff.create');
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:190', 'unique:users,email'],
            'phone' => ['nullable', 'string', 'max:40', 'unique:users,phone'],
            'password' => ['required', 'string', 'min:8'],
            'role' => ['required', Rule::in([UserRole::Admin->value, UserRole::Superadmin->value])],
        ]);

        $user = User::query()->create([
            'name' => $data['name'],
            'email' => $data['email'],
            'phone' => $data['phone'] ?? null,
            'password' => Hash::make($data['password']),
            'role' => $data['role'],
            'onboarding_completed_at' => now(),
        ]);

        AdminActivityLogger::log('staff.create', "Created staff #{$user->id} {$user->name} ({$user->role->value})", $user);

        return redirect()->route('admin.staff.index')->with('success', 'Staff account created.');
    }

    public function edit(User $staff): View
    {
        abort_unless($staff->isStaff(), 404);

        return view('admin.staff.edit', ['staff' => $staff]);
    }

    public function update(Request $request, User $staff): RedirectResponse
    {
        abort_unless($staff->isStaff(), 404);

        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:190', Rule::unique('users', 'email')->ignore($staff->id)],
            'phone' => ['nullable', 'string', 'max:40', Rule::unique('users', 'phone')->ignore($staff->id)],
            'password' => ['nullable', 'string', 'min:8'],
            'role' => ['required', Rule::in([UserRole::Admin->value, UserRole::Superadmin->value])],
        ]);

        // Prevent demoting yourself out of superadmin accidentally locking everyone out.
        if ($staff->id === $request->user()->id && $data['role'] !== UserRole::Superadmin->value) {
            return back()->withErrors(['role' => 'You cannot remove your own superadmin role.']);
        }

        $staff->fill([
            'name' => $data['name'],
            'email' => $data['email'],
            'phone' => $data['phone'] ?? null,
            'role' => $data['role'],
        ]);

        if (! empty($data['password'])) {
            $staff->password = Hash::make($data['password']);
        }

        $staff->save();

        AdminActivityLogger::log('staff.update', "Updated staff #{$staff->id} {$staff->name}", $staff);

        return redirect()->route('admin.staff.index')->with('success', 'Staff account updated.');
    }

    public function destroy(Request $request, User $staff): RedirectResponse
    {
        abort_unless($staff->isStaff(), 404);

        if ($staff->id === $request->user()->id) {
            return back()->withErrors(['staff' => 'You cannot delete your own account.']);
        }

        $label = "#{$staff->id} {$staff->name}";
        $staff->delete();

        AdminActivityLogger::log('staff.delete', "Deleted staff {$label}");

        return redirect()->route('admin.staff.index')->with('success', 'Staff account deleted.');
    }
}
