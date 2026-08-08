<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ForgotPasswordRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Requests\Auth\ResetPasswordRequest;
use App\Http\Resources\AuthTokenResource;
use App\Services\AuthService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    public function __construct(private readonly AuthService $auth)
    {
    }

    public function register(RegisterRequest $request): JsonResponse
    {
        $result = $this->auth->register($request->validated());

        return ApiResponse::resource(new AuthTokenResource($result), 'Registered successfully', 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $result = $this->auth->login(
            $request->validated('identifier'),
            $request->validated('password'),
        );

        return ApiResponse::resource(new AuthTokenResource($result), 'Logged in successfully');
    }

    public function logout(Request $request): JsonResponse
    {
        $this->auth->logout($request->user());

        return ApiResponse::success(null, 'Logged out successfully');
    }

    public function refresh(Request $request): JsonResponse
    {
        $token = $request->user()?->currentAccessToken();
        if ($token === null || ! $token->can('refresh') || $token->can('access')) {
            return ApiResponse::error('Invalid refresh token.', 401, null, 'invalid_refresh_token');
        }

        $result = $this->auth->refresh($request->user(), $token);

        return ApiResponse::resource(new AuthTokenResource($result), 'Token refreshed');
    }

    public function forgotPassword(ForgotPasswordRequest $request): JsonResponse
    {
        $message = $this->auth->forgotPassword($request->validated('email'));

        return ApiResponse::success(null, $message);
    }

    public function resetPassword(ResetPasswordRequest $request): JsonResponse
    {
        $message = $this->auth->resetPassword($request->validated());

        return ApiResponse::success(null, $message);
    }
}