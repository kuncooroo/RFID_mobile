<?php

namespace App\Support;

use App\Models\Admin;
use App\Models\AdminActivityLog;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

final class AdminActivityLogger
{
    public static function log(
        string $action,
        string $description,
        ?Model $subject = null,
        ?Admin $actor = null,
        ?Request $request = null,
    ): void {
        $actor ??= Auth::guard('admin')->user();
        $request ??= request();

        AdminActivityLog::query()->create([
            'admin_id' => $actor?->id,
            'action' => $action,
            'subject_type' => $subject ? $subject::class : null,
            'subject_id' => $subject?->getKey(),
            'description' => $description,
            'ip_address' => $request?->ip(),
        ]);
    }
}
