import '../models/conversation.dart';
import '../models/message.dart';
import 'messaging_repository.dart';
import 'mock_messaging_repository.dart';

/// Local messaging stand-in until Laravel messaging endpoints are wired.
class LocalMessagingRepository implements MessagingRepository {
  LocalMessagingRepository({MockMessagingRepository? delegate})
      : _delegate = delegate ?? MockMessagingRepository.shared;

  final MockMessagingRepository _delegate;

  @override
  Future<List<Conversation>> fetchConversations() =>
      _delegate.fetchConversations();

  @override
  Future<List<Message>> fetchMessages(String threadId) =>
      _delegate.fetchMessages(threadId);

  @override
  Future<void> markConversationRead(String threadId) =>
      _delegate.markConversationRead(threadId);

  @override
  Future<Message> sendMessage({
    required String threadId,
    required String body,
  }) =>
      _delegate.sendMessage(threadId: threadId, body: body);

  @override
  Future<Conversation> findOrCreateStoreConversation({
    required String storeId,
    required String storeName,
    String? avatarUrl,
  }) =>
      _delegate.findOrCreateStoreConversation(
        storeId: storeId,
        storeName: storeName,
        avatarUrl: avatarUrl,
      );
}
