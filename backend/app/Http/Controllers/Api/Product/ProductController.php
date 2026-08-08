<?php

namespace App\Http\Controllers\Api\Product;

use App\Http\Controllers\Controller;
use App\Http\Requests\Product\StoreReviewRequest;
use App\Http\Requests\Search\ProductSearchRequest;
use App\Http\Resources\ProductResource;
use App\Http\Resources\ReviewResource;
use App\Services\ProductService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function __construct(private readonly ProductService $products)
    {
    }

    public function index(ProductSearchRequest $request): JsonResponse
    {
        $paginator = $this->products->search(
            $request->validated(),
            (int) $request->integer('per_page', 15),
        );

        return ApiResponse::resource(ProductResource::collection($paginator));
    }

    public function show(Request $request, int $product): JsonResponse
    {
        return ApiResponse::resource(
            new ProductResource($this->products->show($product, $request->user('sanctum')))
        );
    }

    public function reviews(Request $request, int $product): JsonResponse
    {
        $paginator = $this->products->reviews($product, (int) $request->integer('per_page', 15));

        return ApiResponse::resource(ReviewResource::collection($paginator));
    }

    public function storeReview(StoreReviewRequest $request): JsonResponse
    {
        $review = $this->products->addReview($request->user(), $request->validated());

        return ApiResponse::resource(new ReviewResource($review), 'Review submitted', 201);
    }
}