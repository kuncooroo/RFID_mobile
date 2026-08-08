import '../../../src/network/api_client.dart';
import '../../../src/network/api_endpoints.dart';
import '../models/notification.dart';
import 'notifications_repository.dart';

class RemoteNotificationsRepository implements NotificationsRepository {
  RemoteNotificationsRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    final list = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.notifications,
      parser: _asList,
    );
    return list.map(AppNotification.fromJson).toList();
  }

  @override
  Future<int> unreadCount() async {
    final items = await fetchNotifications();
    return items.where((e) => !e.isRead).length;
  }

  @override
  Future<void> markRead(String id) async {
    await _api.post<dynamic>(ApiEndpoints.notificationRead(id));
  }

  @override
  Future<void> markAllRead() async {
    await _api.post<dynamic>(ApiEndpoints.notificationsReadAll);
  }

  List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
