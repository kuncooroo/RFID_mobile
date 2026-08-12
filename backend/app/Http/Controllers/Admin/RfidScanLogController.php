<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\RfidVerification;
use Illuminate\Http\Request;
use Illuminate\View\View;

class RfidScanLogController extends Controller
{
    public function index(Request $request): View
    {
        $status = trim((string) $request->query('status', ''));

        $scans = RfidVerification::query()
            ->with(['user', 'rfidMember'])
            ->when($status !== '', fn ($q) => $q->where('status', $status))
            ->latest()
            ->paginate(20)
            ->withQueryString();

        return view('admin.rfid.scans', compact('scans', 'status'));
    }
}
