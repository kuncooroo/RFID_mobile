<?php

namespace App\Http\Controllers\Api\Favorite;

use App\Http\Controllers\Controller;
use App\Http\Requests\Favorite\StoreFavoriteRequest;
use App\Http\Resources\FavoriteResource;
use App\Services\FavoriteService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    public function __construct(private readonly FavoriteService $favorites)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $paginator = $this->favorites->list($request->user(), (int) $request->integer('per_page', 15));

        return ApiResponse::resource(FavoriteResource::collection($paginator));
    }

    public function store(StoreFavoriteRequest $request): JsonResponse
    {
        $favorite = $this->favorites->add($request->user(), (int) $request->validated('product_id'));

        return ApiResponse::resource(new FavoriteResource($favorite), 'Added to favorites', 201);
    }

    public function destroy(Request $request, int $product): JsonResponse
    {
        $this->favorites->remove($request->user(), $product);

        return ApiResponse::success(null, 'Removed from favorites');
    }

    public function clear(Request $request): JsonResponse
    {
        $this->favorites->clear($request->user());

        return ApiResponse::success(null, 'Favorites cleared');
    }
}