<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\Admin;
use App\Support\AdminActivityLogger;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class StaffController extends Controller
{
    public function index(): View
    {
        $staff = Admin::query()
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
            'email' => ['required', 'email', 'max:190', 'unique:admins,email'],
            'phone' => ['nullable', 'string', 'max:40', 'unique:admins,phone'],
            'password' => ['required', 'string', 'min:8'],
            'role' => ['required', Rule::in([UserRole::Admin->value, UserRole::Superadmin->value])],
        ]);

        $admin = Admin::query()->create([
            'name' => $data['name'],
            'email' => $data['email'],
            'phone' => $data['phone'] ?? null,
            'password' => $data['password'],
            'role' => $data['role'],
        ]);

        AdminActivityLogger::log('staff.create', "Created staff #{$admin->id} {$admin->name} ({$admin->role->value})", $admin);

        return redirect()->route('admin.staff.index')->with('success', 'Staff account created.');
    }

    public function edit(Admin $staff): View
    {
        return view('admin.staff.edit', ['staff' => $staff]);
    }

    public function update(Request $request, Admin $staff): RedirectResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:190', Rule::unique('admins', 'email')->ignore($staff->id)],
            'phone' => ['nullable', 'string', 'max:40', Rule::unique('admins', 'phone')->ignore($staff->id)],
            'password' => ['nullable', 'string', 'min:8'],
            'role' => ['required', Rule::in([UserRole::Admin->value, UserRole::Superadmin->value])],
        ]);

        $actor = $request->user('admin');
        if ($staff->id === $actor?->id && $data['role'] !== UserRole::Superadmin->value) {
            return back()->withErrors(['role' => 'You cannot remove your own superadmin role.']);
        }

        $staff->fill([
            'name' => $data['name'],
            'email' => $data['email'],
            'phone' => $data['phone'] ?? null,
            'role' => $data['role'],
        ]);

        if (! empty($data['password'])) {
            $staff->password = $data['password'];
        }

        $staff->save();

        AdminActivityLogger::log('staff.update', "Updated staff #{$staff->id} {$staff->name}", $staff);

        return redirect()->route('admin.staff.index')->with('success', 'Staff account updated.');
    }

    public function destroy(Request $request, Admin $staff): RedirectResponse
    {
        $actor = $request->user('admin');
        if ($staff->id === $actor?->id) {
            return back()->withErrors(['staff' => 'You cannot delete your own account.']);
        }

        $label = "#{$staff->id} {$staff->name}";
        $staff->delete();

        AdminActivityLogger::log('staff.delete', "Deleted staff {$label}");

        return redirect()->route('admin.staff.index')->with('success', 'Staff account deleted.');
    }
}
