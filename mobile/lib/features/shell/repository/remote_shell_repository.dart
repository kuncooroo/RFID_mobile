import '../../../src/network/api_client.dart';
import '../../../src/network/api_endpoints.dart';
import '../../notifications/models/notification.dart';
import '../models/shell_badge_summary.dart';
import 'shell_repository.dart';

class RemoteShellRepository implements ShellRepository {
  RemoteShellRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  @override
  Future<ShellBadgeSummary> fetchBadges() async {
    final notifications = await fetchNotifications();
    final unread = notifications.where((n) => !n.isRead).length;

    var activeOrders = 0;
    try {
      final orders = await _api.get<List<dynamic>>(
        ApiEndpoints.orders,
        query: {'per_page': 1},
        parser: (d) => d is List ? d : const [],
        trackLoading: false,
      );
      // meta total is preferred; fall back to list length.
      activeOrders = orders.length;
    } catch (_) {
      activeOrders = 0;
    }

    return ShellBadgeSummary(
      unreadNotifications: unread,
      activeOrders: activeOrders,
    );
  }

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    final list = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.notifications,
      parser: (d) {
        if (d is! List) return <Map<String, dynamic>>[];
        return d
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      },
    );
    return list.map(AppNotification.fromJson).toList();
  }

  @override
  Future<void> markNotificationRead(String id) async {
    await _api.post<dynamic>(ApiEndpoints.notificationRead(id));
  }

  @override
  Future<void> markAllNotificationsRead() async {
    await _api.post<dynamic>(ApiEndpoints.notificationsReadAll);
  }
}
