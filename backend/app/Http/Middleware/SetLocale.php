<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\App;
use Symfony\Component\HttpFoundation\Response;

class SetLocale
{
    public function handle(Request $request, Closure $next): Response
    {
        $locale = $request->header('Accept-Language')
            ?? $request->user()?->settings?->language_code
            ?? config('app.locale');

        $locale = strtolower(substr((string) $locale, 0, 2));

        if (in_array($locale, ['en', 'id', 'ar', 'zh'], true)) {
            App::setLocale($locale);
        }

        return $next($request);
    }
}
