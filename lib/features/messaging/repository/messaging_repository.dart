import '../models/conversation.dart';
import '../models/message.dart';

/// Contract for buyer–seller messaging operations.
abstract class MessagingRepository {
  Future<List<Conversation>> fetchConversations();

  Future<List<Message>> fetchMessages(String threadId);

  Future<Message> sendMessage({
    required String threadId,
    required String body,
  });
}
