import 'package:flutter_riverpod/flutter_riverpod.dart';

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
