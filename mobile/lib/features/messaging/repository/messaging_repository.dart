import '../models/conversation.dart';
import '../models/message.dart';

/// Contract for buyer–seller messaging operations.
abstract class MessagingRepository {
  Future<List<Conversation>> fetchConversations();

  Future<List<Message>> fetchMessages(String threadId);

  Future<void> markConversationRead(String threadId);

  Future<Message> sendMessage({
    required String threadId,
    required String body,
  });

  /// Opens an existing store thread or creates one for Store Detail → Message.
  Future<Conversation> findOrCreateStoreConversation({
    required String storeId,
    required String storeName,
    String? avatarUrl,
  });
}
