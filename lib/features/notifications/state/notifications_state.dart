import '../models/notification.dart';

enum NotificationsStatus { initial, loading, refreshing, ready, failure }

class NotificationsState {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  const NotificationsState.initial() : this();

  final NotificationsStatus status;
  final List<AppNotification> items;
  final String? errorMessage;

  bool get isLoading =>
      status == NotificationsStatus.initial ||
      status == NotificationsStatus.loading;

  bool get isRefreshing => status == NotificationsStatus.refreshing;

  bool get hasFailed => status == NotificationsStatus.failure;

  bool get isEmpty => items.isEmpty;

  int get unreadCount => items.where((n) => !n.isRead).length;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
