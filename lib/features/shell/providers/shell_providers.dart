import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notifications/models/notification.dart';
import '../models/shell_badge_summary.dart';
import '../repository/local_shell_repository.dart';
import '../repository/mock_shell_repository.dart';
import '../repository/shell_repository.dart';
import '../state/shell_state.dart';

/// Pass `--dart-define=USE_MOCK_SHELL=true` to force the mock repository.
const bool kUseMockShellRepository = bool.fromEnvironment(
  'USE_MOCK_SHELL',
  defaultValue: false,
);

final shellRepositoryProvider = Provider<ShellRepository>((ref) {
  if (kUseMockShellRepository) {
    return MockShellRepository();
  }
  return LocalShellRepository();
});

final shellControllerProvider = NotifierProvider<ShellController, ShellState>(
  ShellController.new,
);

final shellNotificationsProvider =
    NotifierProvider<
      ShellNotificationsController,
      AsyncValue<List<AppNotification>>
    >(ShellNotificationsController.new);

class ShellController extends Notifier<ShellState> {
  @override
  ShellState build() => const ShellState.initial();

  Future<void> refresh() async {
    state = state.copyWith(status: ShellStatus.loading, clearError: true);
    try {
      final badges = await ref.read(shellRepositoryProvider).fetchBadges();
      state = state.copyWith(status: ShellStatus.ready, badges: badges);
    } catch (error) {
      state = state.copyWith(
        status: ShellStatus.failure,
        errorMessage: error.toString(),
        badges: const ShellBadgeSummary(),
      );
    }
  }
}

class ShellNotificationsController
    extends Notifier<AsyncValue<List<AppNotification>>> {
  @override
  AsyncValue<List<AppNotification>> build() => const AsyncData([]);

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(shellRepositoryProvider).fetchNotifications(),
    );
  }

  Future<void> markRead(String id) async {
    await ref.read(shellRepositoryProvider).markNotificationRead(id);
    await load();
    await ref.read(shellControllerProvider.notifier).refresh();
  }

  Future<void> markAllRead() async {
    await ref.read(shellRepositoryProvider).markAllNotificationsRead();
    await load();
    await ref.read(shellControllerProvider.notifier).refresh();
  }
}
