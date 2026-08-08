import '../models/notification.dart';

/// Contract for in-app notification inbox operations.
abstract class NotificationsRepository {
  Future<List<AppNotification>> fetchNotifications();

  Future<int> unreadCount();

  Future<void> markRead(String id);

  Future<void> markAllRead();
}
