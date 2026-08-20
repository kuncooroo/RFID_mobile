<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\KioskCheckIn;
use Illuminate\Http\Request;
use Illuminate\View\View;

class RfidScanLogController extends Controller
{
    public function index(Request $request): View
    {
        $status = trim((string) $request->query('status', ''));
        $q = trim((string) $request->query('q', ''));

        $scans = KioskCheckIn::query()
            ->with(['user', 'rfidMember', 'location'])
            ->when($status !== '', fn ($query) => $query->where('status', $status))
            ->when($q !== '', function ($query) use ($q) {
                $query->where(function ($inner) use ($q) {
                    $inner->whereHas('user', function ($user) use ($q) {
                        $user->where('name', 'like', "%{$q}%")
                            ->orWhere('email', 'like', "%{$q}%");
                    })->orWhereHas('rfidMember', function ($rfid) use ($q) {
                        $rfid->where('rfid_uid', 'like', "%{$q}%")
                            ->orWhere('member_code', 'like', "%{$q}%");
                    });
                });
            })
            ->orderByDesc('checked_in_at')
            ->orderByDesc('id')
            ->paginate(20)
            ->withQueryString();

        return view('admin.rfid.scans', compact('scans', 'status', 'q'));
    }
}
