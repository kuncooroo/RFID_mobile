<?php

namespace App\Support;

use App\Models\AdminActivityLog;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\Request;

final class AdminActivityLogger
{
    public static function log(
        string $action,
        string $description,
        ?Model $subject = null,
        ?User $actor = null,
        ?Request $request = null,
    ): void {
        $actor ??= auth()->user();
        $request ??= request();

        AdminActivityLog::query()->create([
            'user_id' => $actor?->id,
            'action' => $action,
            'subject_type' => $subject ? $subject::class : null,
            'subject_id' => $subject?->getKey(),
            'description' => $description,
            'ip_address' => $request?->ip(),
        ]);
    }
}
