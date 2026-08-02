import '../models/conversation.dart';
import '../models/message.dart';

enum MessageDetailStatus { initial, loading, ready, failure }

class MessageDetailState {
  const MessageDetailState({
    this.status = MessageDetailStatus.initial,
    this.conversation,
    this.messages = const [],
    this.errorMessage,
    this.isSending = false,
  });

  const MessageDetailState.initial() : this();

  final MessageDetailStatus status;
  final Conversation? conversation;
  final List<Message> messages;
  final String? errorMessage;
  final bool isSending;

  bool get isLoading =>
      status == MessageDetailStatus.initial ||
      status == MessageDetailStatus.loading;

  bool get hasFailed => status == MessageDetailStatus.failure;

  bool get isEmpty => messages.isEmpty;

  MessageDetailState copyWith({
    MessageDetailStatus? status,
    Conversation? conversation,
    List<Message>? messages,
    String? errorMessage,
    bool clearError = false,
    bool clearConversation = false,
    bool? isSending,
  }) {
    return MessageDetailState(
      status: status ?? this.status,
      conversation: clearConversation
          ? null
          : (conversation ?? this.conversation),
      messages: messages ?? this.messages,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSending: isSending ?? this.isSending,
    );
  }
}
