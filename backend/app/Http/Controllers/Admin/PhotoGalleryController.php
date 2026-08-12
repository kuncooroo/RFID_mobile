<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\RfidVerification;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;
use Symfony\Component\HttpFoundation\StreamedResponse;

class PhotoGalleryController extends Controller
{
    public function index(): View
    {
        $photos = RfidVerification::query()
            ->whereNotNull('captured_image_path')
            ->where('captured_image_path', '!=', '')
            ->with(['user', 'rfidMember'])
            ->latest()
            ->paginate(24);

        return view('admin.gallery.index', compact('photos'));
    }

    public function show(RfidVerification $verification): StreamedResponse
    {
        abort_unless(filled($verification->captured_image_path), 404);

        $disk = Storage::disk('local');
        abort_unless($disk->exists($verification->captured_image_path), 404);

        return $disk->response($verification->captured_image_path);
    }
}
