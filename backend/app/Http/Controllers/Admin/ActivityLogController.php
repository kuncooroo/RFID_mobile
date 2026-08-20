<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminActivityLog;
use Illuminate\Http\Request;
use Illuminate\View\View;

class ActivityLogController extends Controller
{
    public function index(Request $request): View
    {
        $q = trim((string) $request->query('q', ''));

        $logs = AdminActivityLog::query()
            ->with('admin')
            ->when($q !== '', function ($query) use ($q) {
                $query->where(function ($inner) use ($q) {
                    $inner->where('action', 'like', "%{$q}%")
                        ->orWhere('description', 'like', "%{$q}%")
                        ->orWhere('ip_address', 'like', "%{$q}%")
                        ->orWhereHas('admin', function ($admin) use ($q) {
                            $admin->where('name', 'like', "%{$q}%")
                                ->orWhere('email', 'like', "%{$q}%");
                        });
                });
            })
            ->orderBy('id')
            ->paginate(30)
            ->withQueryString();

        return view('admin.activity.index', compact('logs', 'q'));
    }
}
