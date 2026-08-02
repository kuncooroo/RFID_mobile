import '../../notifications/models/notification.dart';
import '../models/shell_badge_summary.dart';
import 'mock_shell_repository.dart';
import 'shell_repository.dart';

/// Production shell stand-in until notifications/orders APIs exist.
///
/// Delegates to the same seeded dataset as [MockShellRepository] so the
/// shell chrome works end-to-end without a backend.
class LocalShellRepository implements ShellRepository {
  LocalShellRepository() : _delegate = MockShellRepository();

  final MockShellRepository _delegate;

  @override
  Future<ShellBadgeSummary> fetchBadges() => _delegate.fetchBadges();

  @override
  Future<List<AppNotification>> fetchNotifications() =>
      _delegate.fetchNotifications();

  @override
  Future<void> markNotificationRead(String id) =>
      _delegate.markNotificationRead(id);

  @override
  Future<void> markAllNotificationsRead() =>
      _delegate.markAllNotificationsRead();
}
