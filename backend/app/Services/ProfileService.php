<?php

namespace App\Services;

use App\Contracts\Repositories\UserRepositoryInterface;
use App\Exceptions\DomainException;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class ProfileService
{
    public function __construct(private readonly UserRepositoryInterface $users)
    {
    }

    public function me(User $user): User
    {
        return $user->load(['member', 'settings']);
    }

    public function updateProfile(User $user, array $data): User
    {
        $user = $this->users->update($user, array_filter([
            'name' => $data['name'] ?? null,
            'email' => $data['email'] ?? null,
            'phone' => $data['phone'] ?? null,
            'avatar_path' => $data['avatar_path'] ?? null,
        ], static fn ($v) => $v !== null));

        if (isset($data['name']) && $user->member) {
            $user->member->update(['display_name' => $data['name']]);
        }

        return $user->load(['member', 'settings']);
    }

    public function changePassword(User $user, string $current, string $new): void
    {
        if (! Hash::check($current, $user->password)) {
            throw new DomainException('Current password is incorrect.', 422, 'invalid_current_password');
        }

        $this->users->update($user, ['password' => $new]);
        $user->tokens()->where('id', '!=', $user->currentAccessToken()?->id)->delete();
    }
}