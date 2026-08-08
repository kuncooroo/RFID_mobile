<?php

namespace App\Http\Controllers\Api\Catalog;

use App\Http\Controllers\Controller;
use App\Http\Resources\CategoryResource;
use App\Http\Resources\ProductResource;
use App\Services\CatalogService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function __construct(private readonly CatalogService $catalog)
    {
    }

    public function index(): JsonResponse
    {
        return ApiResponse::resource(CategoryResource::collection($this->catalog->categories()));
    }

    public function show(int $category): JsonResponse
    {
        return ApiResponse::resource(new CategoryResource($this->catalog->category($category)));
    }

    public function products(Request $request, int $category): JsonResponse
    {
        $paginator = $this->catalog->categoryProducts($category, (int) $request->integer('per_page', 15));

        return ApiResponse::resource(ProductResource::collection($paginator));
    }
}