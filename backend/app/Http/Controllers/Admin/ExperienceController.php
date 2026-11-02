<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\KioskPresence;
use App\Models\User;
use App\Models\UserExperience;
use App\Support\AdminActivityLogger;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ExperienceController extends Controller
{
    public function index(Request $request): View
    {
        $q = trim((string) $request->query('q', ''));

        $visitors = User::query()
            ->where('role', UserRole::Visitor)
            ->with('rfidMember')
            ->withCount('experiences')
            ->when($q !== '', function ($query) use ($q) {
                $query->where(function ($inner) use ($q) {
                    $inner->where('name', 'like', "%{$q}%")
                        ->orWhere('email', 'like', "%{$q}%")
                        ->orWhere('phone', 'like', "%{$q}%");
                });
            })
            ->orderBy('name')
            ->paginate(20)
            ->withQueryString();

        return view('admin.experiences.index', compact('visitors', 'q'));
    }

    public function show(User $visitor): View
    {
        abort_unless($visitor->role === UserRole::Visitor, 404);

        $experiences = $visitor->experiences()->latest()->get();
        $captures = KioskPresence::query()
            ->where('user_id', $visitor->id)
            ->whereNotNull('photo_path')
            ->latest('captured_at')
            ->get();

        return view('admin.experiences.show', compact('visitor', 'experiences', 'captures'));
    }

    public function store(Request $request, User $visitor): RedirectResponse
    {
        abort_unless($visitor->role === UserRole::Visitor, 404);

        $data = $request->validate([
            'title' => ['nullable', 'string', 'max:120'],
            'note' => ['nullable', 'string', 'max:500'],
            'images' => ['required', 'array', 'min:1', 'max:12'],
            'images.*' => ['image', 'max:10240'],
        ]);

        $adminId = $request->user('admin')?->id;
        $count = 0;

        foreach ($request->file('images', []) as $image) {
            $path = $image->store('experiences/'.$visitor->id, 'local');
            $visitor->experiences()->create([
                'title' => $data['title'] ?? null,
                'note' => $data['note'] ?? null,
                'image_path' => $path,
                'admin_id' => $adminId,
            ]);
            $count++;
        }

        AdminActivityLogger::log(
            'experience.store',
            "Stored {$count} experience image(s) for visitor #{$visitor->id}",
            $visitor,
        );

        return back()->with('success', 'Gambar experience tersimpan.');
    }

    public function destroy(User $visitor, UserExperience $experience): RedirectResponse
    {
        abort_unless($experience->user_id === $visitor->id, 404);

        Storage::disk('local')->delete($experience->image_path);
        $experience->delete();

        return back()->with('success', 'Gambar experience dihapus.');
    }

    public function image(User $visitor, UserExperience $experience): StreamedResponse
    {
        abort_unless($experience->user_id === $visitor->id, 404);

        $disk = Storage::disk('local');
        abort_unless($disk->exists($experience->image_path), 404);

        return $disk->response($experience->image_path);
    }

    public function capture(User $visitor, KioskPresence $presence): StreamedResponse
    {
        abort_unless((int) $presence->user_id === (int) $visitor->id, 404);
        abort_unless(is_string($presence->photo_path) && $presence->photo_path !== '', 404);

        $disk = Storage::disk('local');
        abort_unless($disk->exists($presence->photo_path), 404);

        return $disk->response($presence->photo_path);
    }
}
