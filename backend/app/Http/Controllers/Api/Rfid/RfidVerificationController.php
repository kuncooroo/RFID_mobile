<?php

namespace App\Http\Controllers\Api\Rfid;

use App\Http\Controllers\Controller;
use App\Http\Requests\Rfid\RfidVerificationRequest;
use App\Http\Resources\RfidVerificationResource;
use App\Services\RfidVerificationService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RfidVerificationController extends Controller
{
    public function __construct(private readonly RfidVerificationService $rfid)
    {
    }

    public function verify(RfidVerificationRequest $request): JsonResponse
    {
        $result = $this->rfid->verify(
            $request->user(),
            $request->validated('member_id'),
            $request->file('captured_image'),
        );

        return ApiResponse::resource(new RfidVerificationResource($result), $result->message, 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        return ApiResponse::resource(new RfidVerificationResource($this->rfid->show($request->user(), $id)));
    }
}