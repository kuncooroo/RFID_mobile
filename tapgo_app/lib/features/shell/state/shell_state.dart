import '../models/shell_badge_summary.dart';

enum ShellStatus { initial, loading, ready, failure }

class ShellState {
  const ShellState({
    this.status = ShellStatus.initial,
    this.badges = const ShellBadgeSummary(),
    this.errorMessage,
  });

  const ShellState.initial() : this();

  final ShellStatus status;
  final ShellBadgeSummary badges;
  final String? errorMessage;

  bool get isLoading =>
      status == ShellStatus.initial || status == ShellStatus.loading;

  ShellState copyWith({
    ShellStatus? status,
    ShellBadgeSummary? badges,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ShellState(
      status: status ?? this.status,
      badges: badges ?? this.badges,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
