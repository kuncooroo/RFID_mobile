<?php

namespace App\Http\Controllers\Api\Home;

use App\Http\Controllers\Controller;
use App\Http\Resources\HomeFeedResource;
use App\Services\HomeFeedService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;

class HomeController extends Controller
{
    public function __construct(private readonly HomeFeedService $home)
    {
    }

    public function __invoke(): JsonResponse
    {
        return ApiResponse::resource(new HomeFeedResource($this->home->feed()));
    }
}