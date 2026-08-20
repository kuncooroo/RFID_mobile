<?php

namespace App\Http\Controllers\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\KioskCheckIn;
use App\Models\Member;
use App\Models\RfidMember;
use App\Models\User;
use App\Models\UserFaceEnrollment;
use App\Models\UserSetting;
use App\Support\AdminActivityLogger;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\View\View;
use Symfony\Component\HttpFoundation\StreamedResponse;

class VisitorController extends Controller
{
    public function index(Request $request): View
    {
        $q = trim((string) $request->query('q', ''));

        $visitors = User::query()
            ->where('role', UserRole::Visitor)
            ->with(['rfidMember', 'member', 'faceEnrollments'])
            ->when($q !== '', function ($query) use ($q) {
                $query->where(function ($inner) use ($q) {
                    $inner->where('name', 'like', "%{$q}%")
                        ->orWhere('email', 'like', "%{$q}%")
                        ->orWhere('phone', 'like', "%{$q}%")
                        ->orWhereHas('rfidMember', fn ($r) => $r->where('rfid_uid', 'like', "%{$q}%")
                            ->orWhere('member_code', 'like', "%{$q}%"));
                });
            })
            ->orderBy('id')
            ->paginate(15)
            ->withQueryString();

        return view('admin.visitors.index', compact('visitors', 'q'));
    }

    public function create(): View
    {
        $visitor = null;
        $faces = collect(UserFaceEnrollment::poses())->mapWithKeys(fn (string $pose) => [$pose => null]);
        $visitCount = 0;

        return view('admin.visitors.create', compact('visitor', 'faces', 'visitCount'));
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $this->validatedVisitor($request);

        if (empty($data['email']) && empty($data['phone'])) {
            return back()->withInput()->withErrors([
                'email' => 'Provide at least an email or phone.',
            ]);
        }

        try {
            $user = DB::transaction(function () use ($request, $data) {
                $user = User::query()->create([
                    'name' => $data['name'],
                    'email' => $data['email'] ?? null,
                    'phone' => $data['phone'] ?? null,
                    'password' => Hash::make($data['password']),
                    'role' => UserRole::Visitor,
                    'onboarding_completed_at' => now(),
                ]);

                Member::query()->create([
                    'user_id' => $user->id,
                    'display_name' => $user->name,
                    'membership_tier' => 'standard',
                    'points' => 0,
                ]);

                UserSetting::query()->create(['user_id' => $user->id]);
                Cart::query()->create(['user_id' => $user->id, 'currency' => 'USD']);

                $this->syncRfid($user, $data);
                $this->syncFaceUploads($user, $request);

                return $user;
            });
        } catch (\InvalidArgumentException $e) {
            return back()->withInput()->withErrors(['rfid_uid' => $e->getMessage()]);
        }

        AdminActivityLogger::log('visitor.create', "Created visitor #{$user->id} {$user->name}", $user);

        return redirect()
            ->route('admin.visitors.edit', $user)
            ->with('success', 'Visitor created successfully.');
    }

    public function edit(User $visitor): View
    {
        abort_unless($visitor->role === UserRole::Visitor, 404);
        $visitor->load(['rfidMember', 'member', 'faceEnrollments']);

        $faces = collect(UserFaceEnrollment::poses())->mapWithKeys(function (string $pose) use ($visitor) {
            return [$pose => $visitor->faceEnrollments->firstWhere('pose', $pose)];
        });

        $visitCount = KioskCheckIn::query()
            ->where('user_id', $visitor->id)
            ->where('status', 'success')
            ->count();

        return view('admin.visitors.edit', compact('visitor', 'faces', 'visitCount'));
    }

    public function faceImage(User $visitor, string $pose): StreamedResponse
    {
        abort_unless($visitor->role === UserRole::Visitor, 404);
        abort_unless(in_array($pose, UserFaceEnrollment::poses(), true), 404);

        $face = UserFaceEnrollment::query()
            ->where('user_id', $visitor->id)
            ->where('pose', $pose)
            ->firstOrFail();

        $disk = Storage::disk('local');
        abort_unless($disk->exists($face->image_path), 404);

        return $disk->response($face->image_path);
    }

    public function update(Request $request, User $visitor): RedirectResponse
    {
        abort_unless($visitor->role === UserRole::Visitor, 404);
        $visitor->load(['rfidMember', 'member']);

        $data = $this->validatedVisitor($request, $visitor);

        if (empty($data['email']) && empty($data['phone'])) {
            return back()->withInput()->withErrors([
                'email' => 'Provide at least an email or phone.',
            ]);
        }

        try {
            DB::transaction(function () use ($request, $visitor, $data) {
                $visitor->fill([
                    'name' => $data['name'],
                    'email' => $data['email'] ?? null,
                    'phone' => $data['phone'] ?? null,
                ]);

                if (! empty($data['password'])) {
                    $visitor->password = Hash::make($data['password']);
                }

                $visitor->save();

                if ($visitor->member) {
                    $visitor->member->update(['display_name' => $visitor->name]);
                }

                $this->syncRfid($visitor, $data);
                $this->syncFaceUploads($visitor, $request);
            });
        } catch (\InvalidArgumentException $e) {
            return back()->withInput()->withErrors(['rfid_uid' => $e->getMessage()]);
        }

        AdminActivityLogger::log('visitor.update', "Updated visitor #{$visitor->id} {$visitor->name}", $visitor);

        return redirect()
            ->route('admin.visitors.edit', $visitor)
            ->with('success', 'Visitor updated successfully.');
    }

    public function destroy(User $visitor): RedirectResponse
    {
        abort_unless($visitor->role === UserRole::Visitor, 404);

        $label = "#{$visitor->id} {$visitor->name}";

        foreach ($visitor->faceEnrollments as $face) {
            if ($face->image_path) {
                Storage::disk('local')->delete($face->image_path);
            }
        }

        $visitor->forceDelete();

        AdminActivityLogger::log('visitor.delete', "Deleted visitor {$label}");

        return redirect()
            ->route('admin.visitors.index')
            ->with('success', 'Visitor deleted successfully.');
    }

    /**
     * @return array<string, mixed>
     */
    private function validatedVisitor(Request $request, ?User $visitor = null): array
    {
        $request->merge([
            'email' => $this->blankToNull($request->input('email')),
            'phone' => $this->blankToNull($request->input('phone')),
            'rfid_uid' => $this->blankToNull($request->input('rfid_uid')),
            'member_code' => $this->blankToNull($request->input('member_code')),
            'password' => $this->blankToNull($request->input('password')),
        ]);

        $emailRule = Rule::unique('users', 'email');
        $phoneRule = Rule::unique('users', 'phone');
        $rfidRule = Rule::unique('rfid_members', 'rfid_uid');
        $memberCodeRule = Rule::unique('rfid_members', 'member_code');

        if ($visitor) {
            $emailRule = $emailRule->ignore($visitor->id);
            $phoneRule = $phoneRule->ignore($visitor->id);
            if ($visitor->rfidMember) {
                $rfidRule = $rfidRule->ignore($visitor->rfidMember->id);
                $memberCodeRule = $memberCodeRule->ignore($visitor->rfidMember->id);
            }
        }

        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => ['nullable', 'email', 'max:190', $emailRule],
            'phone' => ['nullable', 'string', 'max:40', $phoneRule],
            'password' => [$visitor ? 'nullable' : 'required', 'string', 'min:8'],
            'rfid_uid' => ['nullable', 'string', 'max:100', $rfidRule],
            'member_code' => ['nullable', 'string', 'max:100', $memberCodeRule],
            'rfid_is_active' => ['nullable', Rule::in(['0', '1', 0, 1, true, false])],
            'face_front' => ['nullable', 'image', 'max:10240'],
            'face_right' => ['nullable', 'image', 'max:10240'],
            'face_left' => ['nullable', 'image', 'max:10240'],
            'clear_face_front' => ['nullable', 'boolean'],
            'clear_face_right' => ['nullable', 'boolean'],
            'clear_face_left' => ['nullable', 'boolean'],
        ]);

        $data['rfid_is_active'] = $request->boolean('rfid_is_active', true);

        return $data;
    }

    private function blankToNull(mixed $value): ?string
    {
        if ($value === null) {
            return null;
        }

        $trimmed = trim((string) $value);

        return $trimmed === '' ? null : $trimmed;
    }

    /**
     * @param  array<string, mixed>  $data
     */
    private function syncRfid(User $user, array $data): void
    {
        $rfidUid = trim((string) ($data['rfid_uid'] ?? ''));
        $memberCode = trim((string) ($data['member_code'] ?? ''));
        $isActive = (bool) ($data['rfid_is_active'] ?? true);

        if ($rfidUid === '') {
            if ($user->rfidMember) {
                $user->rfidMember->update([
                    'user_id' => null,
                    'is_active' => false,
                ]);
            }

            return;
        }

        $existingForUid = RfidMember::query()
            ->where('rfid_uid', $rfidUid)
            ->where(function ($q) use ($user) {
                $q->whereNull('user_id')->orWhere('user_id', '!=', $user->id);
            })
            ->first();

        if ($existingForUid && $existingForUid->user_id !== null) {
            throw new \InvalidArgumentException('This RFID UID is already bound to another visitor.');
        }

        if ($memberCode === '') {
            $memberCode = $user->rfidMember?->member_code
                ?: 'MEM-'.str_pad((string) $user->id, 5, '0', STR_PAD_LEFT);
        }

        $card = $user->rfidMember;

        if ($existingForUid && $existingForUid->user_id === null) {
            if ($card && $card->id !== $existingForUid->id) {
                $card->update(['user_id' => null, 'is_active' => false]);
            }
            $existingForUid->update([
                'user_id' => $user->id,
                'member_code' => $memberCode,
                'is_active' => $isActive,
            ]);

            return;
        }

        if ($card) {
            $card->update([
                'rfid_uid' => $rfidUid,
                'member_code' => $memberCode,
                'is_active' => $isActive,
            ]);

            return;
        }

        RfidMember::query()->create([
            'user_id' => $user->id,
            'rfid_uid' => $rfidUid,
            'member_code' => $memberCode ?: 'MEM-'.Str::upper(Str::random(6)),
            'is_active' => $isActive,
        ]);
    }

    private function syncFaceUploads(User $user, Request $request): void
    {
        $map = [
            'front' => 'face_front',
            'right' => 'face_right',
            'left' => 'face_left',
        ];

        foreach ($map as $pose => $field) {
            if ($request->boolean('clear_'.$field)) {
                $existing = UserFaceEnrollment::query()
                    ->where('user_id', $user->id)
                    ->where('pose', $pose)
                    ->first();
                if ($existing) {
                    Storage::disk('local')->delete($existing->image_path);
                    $existing->delete();
                }
            }

            $file = $request->file($field);
            if (! $file instanceof UploadedFile) {
                continue;
            }

            $path = $file->store("rfid/enrollments/{$user->id}", 'local');
            $existing = UserFaceEnrollment::query()
                ->where('user_id', $user->id)
                ->where('pose', $pose)
                ->first();

            if ($existing?->image_path) {
                Storage::disk('local')->delete($existing->image_path);
            }

            UserFaceEnrollment::query()->updateOrCreate(
                ['user_id' => $user->id, 'pose' => $pose],
                [
                    'image_path' => $path,
                    'enrolled_at' => now(),
                ],
            );
        }
    }
}
