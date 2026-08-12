<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/** Blocks staff accounts from using visitor-only surfaces if needed later. */
class EnsureStaffUser
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if ($user === null || ! $user->isStaff()) {
            return redirect()->route('admin.login');
        }

        return $next($request);
    }
}
