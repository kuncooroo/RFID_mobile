import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/local_notifications_repository.dart';
import '../repository/mock_notifications_repository.dart';
import '../repository/notifications_repository.dart';
import '../state/notifications_state.dart';

/// Pass `--dart-define=USE_MOCK_NOTIFICATIONS=true` to force the mock repository.
const bool kUseMockNotificationsRepository = bool.fromEnvironment(
  'USE_MOCK_NOTIFICATIONS',
  defaultValue: false,
);

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  if (kUseMockNotificationsRepository) {
    return MockNotificationsRepository.shared;
  }
  return LocalNotificationsRepository();
});

final notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationsState>(
      NotificationsController.new,
    );

class NotificationsController extends Notifier<NotificationsState> {
  @override
  NotificationsState build() => const NotificationsState.initial();

  Future<void> load() async {
    if (state.status == NotificationsStatus.loading) return;
    state = state.copyWith(
      status: NotificationsStatus.loading,
      clearError: true,
    );
    await _fetch(status: NotificationsStatus.ready);
  }

  Future<void> refresh() async {
    state = state.copyWith(
      status: NotificationsStatus.refreshing,
      clearError: true,
    );
    await _fetch(status: NotificationsStatus.ready);
  }

  Future<void> _fetch({required NotificationsStatus status}) async {
    try {
      final items =
          await ref.read(notificationsRepositoryProvider).fetchNotifications();
      state = state.copyWith(status: status, items: items);
    } catch (error) {
      state = state.copyWith(
        status: NotificationsStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> markRead(String id) async {
    await ref.read(notificationsRepositoryProvider).markRead(id);
    final updated = [
      for (final item in state.items)
        if (item.id == id) item.copyWith(isRead: true) else item,
    ];
    state = state.copyWith(items: updated);
  }

  Future<void> markAllRead() async {
    await ref.read(notificationsRepositoryProvider).markAllRead();
    final updated = [
      for (final item in state.items) item.copyWith(isRead: true),
    ];
    state = state.copyWith(items: updated);
  }
}
