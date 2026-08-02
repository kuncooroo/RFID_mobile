import '../../notifications/models/notification.dart';
import '../models/shell_badge_summary.dart';

/// Contract for shell chrome data (badges + notification inbox preview).
abstract class ShellRepository {
  Future<ShellBadgeSummary> fetchBadges();

  Future<List<AppNotification>> fetchNotifications();

  Future<void> markNotificationRead(String id);

  Future<void> markAllNotificationsRead();
}
