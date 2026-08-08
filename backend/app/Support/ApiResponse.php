<?php

namespace App\Support;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Http\Resources\Json\ResourceCollection;
use Illuminate\Pagination\AbstractPaginator;

final class ApiResponse
{
    public static function success(
        mixed $data = null,
        ?string $message = null,
        int $status = 200,
        ?array $meta = null,
    ): JsonResponse {
        $payload = [
            'success' => true,
            'message' => $message,
            'data' => self::normalizeData($data),
        ];

        if ($meta !== null) {
            $payload['meta'] = $meta;
        }

        if ($data instanceof AbstractPaginator) {
            $payload['meta'] = array_merge($payload['meta'] ?? [], [
                'current_page' => $data->currentPage(),
                'per_page' => $data->perPage(),
                'total' => $data->total(),
                'last_page' => $data->lastPage(),
            ]);
            $payload['data'] = $data->items();
        }

        return response()->json($payload, $status);
    }

    public static function created(mixed $data = null, ?string $message = 'Created successfully'): JsonResponse
    {
        return self::success($data, $message, 201);
    }

    public static function error(
        string $message,
        int $status = 400,
        mixed $errors = null,
        ?string $code = null,
    ): JsonResponse {
        return response()->json([
            'success' => false,
            'message' => $message,
            'code' => $code,
            'errors' => $errors,
            'data' => null,
        ], $status);
    }

    public static function resource(
        JsonResource|ResourceCollection $resource,
        ?string $message = null,
        int $status = 200,
    ): JsonResponse {
        $resolved = $resource->response()->getData(true);

        $data = $resolved['data'] ?? $resolved;
        $meta = $resolved['meta'] ?? null;
        $links = $resolved['links'] ?? null;

        $payload = [
            'success' => true,
            'message' => $message,
            'data' => $data,
        ];

        if ($meta !== null || $links !== null) {
            $payload['meta'] = array_filter([
                'current_page' => $meta['current_page'] ?? null,
                'per_page' => $meta['per_page'] ?? null,
                'total' => $meta['total'] ?? null,
                'last_page' => $meta['last_page'] ?? null,
                'links' => $links,
            ], static fn ($value) => $value !== null);
        }

        return response()->json($payload, $status);
    }

    private static function normalizeData(mixed $data): mixed
    {
        if ($data instanceof JsonResource || $data instanceof ResourceCollection) {
            return $data->resolve();
        }

        return $data;
    }
}
