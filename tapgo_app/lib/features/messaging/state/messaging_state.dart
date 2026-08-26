import '../models/conversation.dart';

enum MessagingStatus { initial, loading, refreshing, ready, failure }

class MessagingState {
  const MessagingState({
    this.status = MessagingStatus.initial,
    this.conversations = const [],
    this.errorMessage,
  });

  const MessagingState.initial() : this();

  final MessagingStatus status;
  final List<Conversation> conversations;
  final String? errorMessage;

  bool get isLoading =>
      status == MessagingStatus.initial || status == MessagingStatus.loading;

  bool get isRefreshing => status == MessagingStatus.refreshing;

  bool get hasFailed => status == MessagingStatus.failure;

  bool get isEmpty => conversations.isEmpty;

  int get totalUnread =>
      conversations.fold(0, (sum, item) => sum + item.unreadCount);

  MessagingState copyWith({
    MessagingStatus? status,
    List<Conversation>? conversations,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MessagingState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
