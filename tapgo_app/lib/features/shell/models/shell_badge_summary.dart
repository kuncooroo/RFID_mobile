import '../../notifications/models/notification.dart';

/// Unread badge summary for shell chrome (bell + optional order badge).
class ShellBadgeSummary {
  const ShellBadgeSummary({
    this.unreadNotifications = 0,
    this.activeOrders = 0,
  });

  final int unreadNotifications;
  final int activeOrders;

  bool get hasUnreadNotifications => unreadNotifications > 0;

  ShellBadgeSummary copyWith({int? unreadNotifications, int? activeOrders}) {
    return ShellBadgeSummary(
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      activeOrders: activeOrders ?? this.activeOrders,
    );
  }
}

/// Lightweight shell feed for the notifications screen until the full
/// notifications feature owns this surface.
class ShellNotificationsFeed {
  const ShellNotificationsFeed({this.items = const []});

  final List<AppNotification> items;

  int get unreadCount => items.where((n) => !n.isRead).length;
}
