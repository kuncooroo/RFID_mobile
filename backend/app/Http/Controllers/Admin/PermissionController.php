<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\RolePermission;
use App\Support\AdminAccess;
use App\Support\AdminActivityLogger;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

class PermissionController extends Controller
{
    public function edit(): View
    {
        $granted = RolePermission::query()
            ->get()
            ->groupBy('role')
            ->map(fn ($rows) => $rows->pluck('permission')->all());

        $order = [
            UserRole::Superadmin,
            UserRole::Finance,
            UserRole::Staff,
            UserRole::Admin,
        ];
        $roles = array_values(array_filter(
            $order,
            fn (UserRole $role) => $role->isStaff(),
        ));

        return view('admin.permissions.edit', [
            'catalog' => AdminAccess::catalog(),
            'roles' => $roles,
            'granted' => $granted,
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $catalog = array_keys(AdminAccess::catalog());
        $input = $request->input('permissions', []);
        if (! is_array($input)) {
            $input = [];
        }

        DB::transaction(function () use ($catalog, $input) {
            RolePermission::query()->delete();

            foreach (UserRole::staffValues() as $role) {
                $selected = $role === UserRole::Superadmin->value
                    ? $catalog
                    : array_values(array_intersect(
                        $catalog,
                        array_keys(is_array($input[$role] ?? null) ? $input[$role] : []),
                    ));

                foreach ($selected as $permission) {
                    RolePermission::query()->create([
                        'role' => $role,
                        'permission' => $permission,
                    ]);
                }
            }
        });

        AdminActivityLogger::log('permissions.update', 'Updated role permission matrix');

        return back()->with('success', 'Izin peran disimpan.');
    }
}
