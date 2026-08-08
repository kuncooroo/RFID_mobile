<?php

namespace App\Http\Controllers\Api\Profile;

use App\Http\Controllers\Controller;
use App\Http\Requests\Settings\UpdateSettingsRequest;
use App\Http\Resources\SettingsResource;
use App\Services\SettingsService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SettingsController extends Controller
{
    public function __construct(private readonly SettingsService $settings)
    {
    }

    public function show(Request $request): JsonResponse
    {
        return ApiResponse::resource(new SettingsResource($this->settings->get($request->user())));
    }

    public function update(UpdateSettingsRequest $request): JsonResponse
    {
        $setting = $this->settings->update($request->user(), $request->validated());

        return ApiResponse::resource(new SettingsResource($setting), 'Settings updated');
    }

    public function languages(): JsonResponse
    {
        return ApiResponse::success($this->settings->languages());
    }
}