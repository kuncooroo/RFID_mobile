import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared network loading counter (data-layer only; UI unchanged).
class NetworkLoadingNotifier extends Notifier<int> {
  @override
  int build() => 0;

  bool get isLoading => state > 0;

  void begin() => state = state + 1;

  void end() {
    if (state == 0) return;
    state = state - 1;
  }
}

final networkLoadingProvider =
    NotifierProvider<NetworkLoadingNotifier, int>(NetworkLoadingNotifier.new);

final isNetworkLoadingProvider = Provider<bool>((ref) {
  return ref.watch(networkLoadingProvider) > 0;
});
