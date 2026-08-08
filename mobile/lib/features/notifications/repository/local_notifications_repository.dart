import '../models/notification.dart';
import 'mock_notifications_repository.dart';
import 'notifications_repository.dart';

/// Local notifications stand-in until Laravel notification endpoints are wired.
class LocalNotificationsRepository implements NotificationsRepository {
  LocalNotificationsRepository({MockNotificationsRepository? delegate})
      : _delegate = delegate ?? MockNotificationsRepository.shared;

  final MockNotificationsRepository _delegate;

  @override
  Future<List<AppNotification>> fetchNotifications() =>
      _delegate.fetchNotifications();

  @override
  Future<int> unreadCount() => _delegate.unreadCount();

  @override
  Future<void> markRead(String id) => _delegate.markRead(id);

  @override
  Future<void> markAllRead() => _delegate.markAllRead();
}
