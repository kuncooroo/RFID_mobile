<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminActivityLog;
use Illuminate\View\View;

class ActivityLogController extends Controller
{
    public function index(): View
    {
        $logs = AdminActivityLog::query()
            ->with('user')
            ->latest()
            ->paginate(30);

        return view('admin.activity.index', compact('logs'));
    }
}
