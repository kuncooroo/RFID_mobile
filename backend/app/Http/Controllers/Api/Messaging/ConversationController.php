<?php

namespace App\Http\Controllers\Api\Messaging;

use App\Http\Controllers\Controller;
use App\Http\Requests\Messaging\OpenConversationRequest;
use App\Http\Requests\Messaging\StoreMessageRequest;
use App\Http\Resources\ConversationResource;
use App\Http\Resources\MessageResource;
use App\Services\ConversationService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ConversationController extends Controller
{
    public function __construct(private readonly ConversationService $conversations)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $paginator = $this->conversations->list($request->user(), (int) $request->integer('per_page', 15));

        return ApiResponse::resource(ConversationResource::collection($paginator));
    }

    public function store(OpenConversationRequest $request): JsonResponse
    {
        $conversation = $this->conversations->open($request->user(), (int) $request->validated('store_id'));

        return ApiResponse::resource(new ConversationResource($conversation), 'Conversation opened', 201);
    }

    public function messages(Request $request, int $conversation): JsonResponse
    {
        $paginator = $this->conversations->messages(
            $request->user(),
            $conversation,
            (int) $request->integer('per_page', 30),
        );

        return ApiResponse::resource(MessageResource::collection($paginator));
    }

    public function send(StoreMessageRequest $request, int $conversation): JsonResponse
    {
        $message = $this->conversations->send($request->user(), $conversation, $request->validated());

        return ApiResponse::resource(new MessageResource($message), 'Message sent', 201);
    }

    public function markRead(Request $request, int $conversation): JsonResponse
    {
        $this->conversations->markRead($request->user(), $conversation);

        return ApiResponse::success(null, 'Conversation marked as read');
    }
}