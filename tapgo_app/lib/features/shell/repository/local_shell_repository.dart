import '../../notifications/models/notification.dart';
import '../../notifications/repository/local_notifications_repository.dart';
import '../../notifications/repository/notifications_repository.dart';
import '../../orders/repository/local_orders_repository.dart';
import '../../orders/repository/orders_repository.dart';
import '../models/shell_badge_summary.dart';
import 'shell_repository.dart';

/// Production shell stand-in until notifications/orders APIs exist.
class LocalShellRepository implements ShellRepository {
  LocalShellRepository({
    NotificationsRepository? notifications,
    OrdersRepository? orders,
  })  : _notifications = notifications ?? LocalNotificationsRepository(),
        _orders = orders ?? LocalOrdersRepository();

  final NotificationsRepository _notifications;
  final OrdersRepository _orders;

  @override
  Future<ShellBadgeSummary> fetchBadges() async {
    final unread = await _notifications.unreadCount();
    final feed = await _orders.fetchOrdersFeed();
    return ShellBadgeSummary(
      unreadNotifications: unread,
      activeOrders: feed.activeCount,
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
