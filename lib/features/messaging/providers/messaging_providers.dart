import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/conversation.dart';
import '../repository/local_messaging_repository.dart';
import '../repository/messaging_repository.dart';
import '../repository/mock_messaging_repository.dart';
import '../state/message_detail_state.dart';
import '../state/messaging_state.dart';

/// Pass `--dart-define=USE_MOCK_MESSAGING=true` to force the mock repository.
const bool kUseMockMessagingRepository = bool.fromEnvironment(
  'USE_MOCK_MESSAGING',
  defaultValue: false,
);

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  if (kUseMockMessagingRepository) {
    return MockMessagingRepository.shared;
  }
  return LocalMessagingRepository();
});

final messagingControllerProvider =
    NotifierProvider<MessagingController, MessagingState>(
      MessagingController.new,
    );

final messageDetailControllerProvider = NotifierProvider.family<
    MessageDetailController,
    MessageDetailState,
    String>(MessageDetailController.new);

class MessagingController extends Notifier<MessagingState> {
  @override
  MessagingState build() => const MessagingState.initial();

  Future<void> load() async {
    if (state.status == MessagingStatus.loading) return;
    state = state.copyWith(status: MessagingStatus.loading, clearError: true);
    await _fetch(status: MessagingStatus.ready);
  }

  Future<void> refresh() async {
    state = state.copyWith(
      status: MessagingStatus.refreshing,
      clearError: true,
    );
    await _fetch(status: MessagingStatus.ready);
  }

  Future<void> _fetch({required MessagingStatus status}) async {
    try {
      final conversations = await ref
          .read(messagingRepositoryProvider)
          .fetchConversations();
      state = state.copyWith(status: status, conversations: conversations);
    } catch (error) {
      state = state.copyWith(
        status: MessagingStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Conversation? conversationById(String threadId) {
    for (final conversation in state.conversations) {
      if (conversation.id == threadId) return conversation;
    }
    return null;
  }

  Future<Conversation?> openStoreConversation({
    required String storeId,
    required String storeName,
    String? avatarUrl,
  }) async {
    try {
      final conversation = await ref
          .read(messagingRepositoryProvider)
          .findOrCreateStoreConversation(
            storeId: storeId,
            storeName: storeName,
            avatarUrl: avatarUrl,
          );
      await refresh();
      return conversation;
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
      return null;
    }
  }
}

class MessageDetailController extends Notifier<MessageDetailState> {
  MessageDetailController(this.threadId);

  final String threadId;

  @override
  MessageDetailState build() => const MessageDetailState.initial();

  Future<void> load() async {
    state = state.copyWith(
      status: MessageDetailStatus.loading,
      clearError: true,
    );

    final messaging = ref.read(messagingControllerProvider.notifier);
    if (ref.read(messagingControllerProvider).conversations.isEmpty) {
      await messaging.load();
    }

    var conversation = messaging.conversationById(threadId);

    try {
      final messages = await ref
          .read(messagingRepositoryProvider)
          .fetchMessages(threadId);
      conversation = messaging.conversationById(threadId) ?? conversation;
      state = state.copyWith(
        status: MessageDetailStatus.ready,
        conversation: conversation,
        messages: messages,
      );
      // Refresh list so unread badges clear without blocking chat UI.
      unawaited(messaging.refresh());
    } catch (error) {
      state = state.copyWith(
        status: MessageDetailStatus.failure,
        errorMessage: error.toString(),
        conversation: conversation,
        clearConversation: conversation == null,
      );
    }
  }

  Future<void> send(String body) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty || state.isSending) return;

    state = state.copyWith(isSending: true, clearError: true);
    try {
      final message = await ref
          .read(messagingRepositoryProvider)
          .sendMessage(threadId: threadId, body: trimmed);
      state = state.copyWith(
        messages: [...state.messages, message],
        isSending: false,
        conversation: state.conversation?.copyWith(
          lastMessage: trimmed,
          lastMessageAt: message.sentAt,
          unreadCount: 0,
        ),
      );
      unawaited(ref.read(messagingControllerProvider.notifier).refresh());
    } catch (error) {
      state = state.copyWith(
        isSending: false,
        errorMessage: error.toString(),
      );
    }
  }
}
