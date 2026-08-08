<?php

namespace App\Services;

use App\Contracts\Repositories\UserRepositoryInterface;
use App\Exceptions\DomainException;
use App\Models\Cart;
use App\Models\Member;
use App\Models\User;
use App\Models\UserSetting;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Validation\ValidationException;
use Laravel\Sanctum\PersonalAccessToken;

class AuthService
{
    public function __construct(private readonly UserRepositoryInterface $users)
    {
    }

    /**
     * @param  array{name:string,email?:string|null,phone?:string|null,password:string}  $data
     * @return array{user:User,token:string,refresh_token:string}
     */
    public function register(array $data): array
    {
        return DB::transaction(function () use ($data) {
            /** @var User $user */
            $user = $this->users->create([
                'name' => $data['name'],
                'email' => $data['email'] ?? null,
                'phone' => $data['phone'] ?? null,
                'password' => $data['password'],
            ]);

            Member::query()->create([
                'user_id' => $user->id,
                'display_name' => $data['name'],
            ]);

            UserSetting::query()->create([
                'user_id' => $user->id,
            ]);

            Cart::query()->create([
                'user_id' => $user->id,
            ]);

            return $this->issueTokenPair($user->load(['member', 'settings']));
        });
    }

    /**
     * @return array{user:User,token:string,refresh_token:string}
     */
    public function login(string $identifier, string $password): array
    {
        $user = $this->users->findByIdentifier($identifier);

        if (! $user || ! Hash::check($password, $user->password)) {
            throw ValidationException::withMessages([
                'identifier' => ['The provided credentials are incorrect.'],
            ]);
        }

        return $this->issueTokenPair($user->load(['member', 'settings']));
    }

    /**
     * Rotate the presented refresh token only (keeps other devices signed in).
     *
     * @return array{user:User,token:string,refresh_token:string}
     */
    public function refresh(User $user, mixed $currentToken = null): array
    {
        if ($currentToken instanceof PersonalAccessToken) {
            $currentToken->delete();
        }

        return $this->issueTokenPair($user->load(['member', 'settings']));
    }

    public function logout(User $user): void
    {
        $user->currentAccessToken()?->delete();
    }

    /**
     * @return array{user:User,token:string,refresh_token:string}
     */
    private function issueTokenPair(User $user): array
    {
        $access = $user->createToken(
            'access',
            ['access'],
            now()->addHours(12),
        )->plainTextToken;

        $refresh = $user->createToken(
            'refresh',
            ['refresh'],
            now()->addDays(30),
        )->plainTextToken;

        return [
            'user' => $user,
            'token' => $access,
            'refresh_token' => $refresh,
        ];
    }

    public function forgotPassword(string $email): string
    {
        $status = Password::sendResetLink(['email' => $email]);

        if ($status !== Password::RESET_LINK_SENT) {
            throw new DomainException(__($status), 422);
        }

        return __($status);
    }

    /**
     * @param  array{email:string,token:string,password:string}  $data
     */
    public function resetPassword(array $data): string
    {
        $status = Password::reset(
            [
                'email' => $data['email'],
                'password' => $data['password'],
                'password_confirmation' => $data['password'],
                'token' => $data['token'],
            ],
            function (User $user, string $password) {
                $user->forceFill(['password' => $password])->save();
                $user->tokens()->delete();
            }
        );

        if ($status !== Password::PASSWORD_RESET) {
            throw new DomainException(__($status), 422);
        }

        return __($status);
    }
}
