import '../../notifications/models/notification.dart';
import '../models/shell_badge_summary.dart';
import 'shell_repository.dart';

/// In-memory shell repository for tests and UI demos.
class MockShellRepository implements ShellRepository {
  MockShellRepository({
    List<AppNotification>? notifications,
    this.activeOrders = 2,
  }) : _notifications = List<AppNotification>.from(notifications ?? _defaults);

  final List<AppNotification> _notifications;
  final int activeOrders;

  static final _defaults = <AppNotification>[
    AppNotification(
      id: '1',
      title: 'Order shipped',
      body: 'Your order #KU-1042 is on the way.',
      type: NotificationType.order,
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    AppNotification(
      id: '2',
      title: 'Weekend promo',
      body: 'Get 20% off selected fashion items.',
      type: NotificationType.promo,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AppNotification(
      id: '3',
      title: 'Payment success',
      body: 'Payment for order #KU-1038 was successful.',
      type: NotificationType.payment,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Future<ShellBadgeSummary> fetchBadges() async {
    return ShellBadgeSummary(
      unreadNotifications: _notifications.where((n) => !n.isRead).length,
      activeOrders: activeOrders,
    );
  }

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    return List<AppNotification>.unmodifiable(_notifications);
  }

  @override
  Future<void> markNotificationRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index < 0) return;
    _notifications[index] = _notifications[index].copyWith(isRead: true);
  }

  @override
  Future<void> markAllNotificationsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }
}
