<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Optional shared secret for kiosk machines.
 * If KIOSK_API_KEY is empty in .env, the check is skipped (local/dev friendly).
 */
class EnsureKioskApiKey
{
    public function handle(Request $request, Closure $next): Response
    {
        $expected = (string) config('services.kiosk.api_key', '');
        if ($expected === '') {
            return $next($request);
        }

        $provided = (string) $request->header('X-Kiosk-Key', '');
        if (! hash_equals($expected, $provided)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid kiosk API key.',
                'code' => 'kiosk_unauthorized',
                'errors' => null,
                'data' => null,
            ], 401);
        }

        return $next($request);
    }
}
