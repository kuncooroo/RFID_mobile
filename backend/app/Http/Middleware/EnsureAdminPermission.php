<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureAdminPermission
{
    public function handle(Request $request, Closure $next, string $permission): Response
    {
        $admin = $request->user('admin');

        if ($admin === null || ! $admin->allows($permission)) {
            abort(403, 'Anda tidak punya izin untuk halaman ini.');
        }

        return $next($request);
    }
}
