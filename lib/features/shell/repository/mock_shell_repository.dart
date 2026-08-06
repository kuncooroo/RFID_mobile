import '../../notifications/models/notification.dart';
import '../../notifications/repository/mock_notifications_repository.dart';
import '../../orders/repository/mock_orders_repository.dart';
import '../models/shell_badge_summary.dart';
import 'shell_repository.dart';

/// In-memory shell repository for tests and UI demos.
///
/// Badge unread count comes from the shared notifications store.
class MockShellRepository implements ShellRepository {
  MockShellRepository({
    this.activeOrders,
    MockNotificationsRepository? notifications,
  }) : _notifications = notifications ?? MockNotificationsRepository.shared;

  final MockNotificationsRepository _notifications;
  final int? activeOrders;

  @override
  Future<ShellBadgeSummary> fetchBadges() async {
    final unread = await _notifications.unreadCount();
    final orders = activeOrders ??
        (await MockOrdersRepository.shared.fetchOrdersFeed()).activeCount;
    return ShellBadgeSummary(
      unreadNotifications: unread,
      activeOrders: orders,
    );
  }

  @override
  Future<List<AppNotification>> fetchNotifications() =>
      _notifications.fetchNotifications();

  @override
  Future<void> markNotificationRead(String id) =>
      _notifications.markRead(id);

  @override
  Future<void> markAllNotificationsRead() => _notifications.markAllRead();
}
