<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\RfidVerification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;
use Symfony\Component\HttpFoundation\StreamedResponse;

class PhotoGalleryController extends Controller
{
    public function index(Request $request): View
    {
        $q = trim((string) $request->query('q', ''));

        $photos = RfidVerification::query()
            ->whereNotNull('captured_image_path')
            ->where('captured_image_path', '!=', '')
            ->with(['user.rfidMember', 'rfidMember'])
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
            ->orderBy('id')
            ->get();

        $groups = $photos
            ->groupBy(fn (RfidVerification $photo) => $photo->user_id ?? 0)
            ->map(function ($items, $userId) {
                /** @var \Illuminate\Support\Collection<int, RfidVerification> $items */
                $sorted = $items->sortBy('id')->values();
                $first = $sorted->first();
                $user = $first?->user;
                $rfid = $user?->rfidMember ?? $first?->rfidMember;

                return [
                    'user_id' => (int) $userId,
                    'name' => $user?->name ?? 'Unknown / Unbound',
                    'email' => $user?->email,
                    'member_code' => $rfid?->member_code,
                    'rfid_uid' => $rfid?->rfid_uid,
                    'count' => $sorted->count(),
                    'photos' => $sorted,
                    'first_id' => (int) ($first?->id ?? 0),
                ];
            })
            ->sortBy(fn (array $group) => $group['user_id'] === 0 ? PHP_INT_MAX : $group['first_id'])
            ->values();

        return view('admin.gallery.index', compact('groups', 'q'));
    }

    public function show(RfidVerification $verification): StreamedResponse
    {
        abort_unless(filled($verification->captured_image_path), 404);

        $disk = Storage::disk('local');
        abort_unless($disk->exists($verification->captured_image_path), 404);

        return $disk->response($verification->captured_image_path);
    }
}
