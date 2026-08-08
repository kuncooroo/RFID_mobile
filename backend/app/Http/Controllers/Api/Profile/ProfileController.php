<?php

namespace App\Http\Controllers\Api\Profile;

use App\Http\Controllers\Controller;
use App\Http\Requests\Profile\ChangePasswordRequest;
use App\Http\Requests\Profile\UpdateProfileRequest;
use App\Http\Resources\UserResource;
use App\Services\ProfileService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function __construct(private readonly ProfileService $profiles)
    {
    }

    public function me(Request $request): JsonResponse
    {
        return ApiResponse::resource(new UserResource($this->profiles->me($request->user())));
    }

    public function update(UpdateProfileRequest $request): JsonResponse
    {
        $user = $this->profiles->updateProfile($request->user(), $request->validated());

        return ApiResponse::resource(new UserResource($user), 'Profile updated');
    }

    public function changePassword(ChangePasswordRequest $request): JsonResponse
    {
        $this->profiles->changePassword(
            $request->user(),
            $request->validated('current_password'),
            $request->validated('password'),
        );

        return ApiResponse::success(null, 'Password changed successfully');
    }
}