<?php

namespace App\Http\Middleware;

use App\Enums\UserRole;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Restricts web admin routes to users whose role is in the allowed list.
 *
 * Usage: middleware('role:admin,superadmin') or middleware('role:superadmin')
 */
class EnsureUserHasRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if ($user === null) {
            return redirect()->route('admin.login');
        }

        $allowed = collect($roles)
            ->flatMap(fn (string $role) => explode(',', $role))
            ->map(fn (string $role) => trim($role))
            ->filter()
            ->values()
            ->all();

        $current = $user->role instanceof UserRole
            ? $user->role->value
            : (string) $user->role;

        if (! in_array($current, $allowed, true)) {
            abort(403, 'You do not have permission to access this area.');
        }

        return $next($request);
    }
}
