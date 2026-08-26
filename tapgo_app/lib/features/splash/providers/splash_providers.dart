import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/auth_session.dart';
import '../../../src/storage/secure_storage_service.dart';
import '../models/splash_bootstrap_result.dart';
import '../models/splash_statistic.dart';
import '../repository/mock_splash_repository.dart';
import '../repository/splash_repository.dart';
import '../state/splash_state.dart';
import '../../../src/network/api_client.dart';
import '../repository/remote_splash_repository.dart';

/// Use mock repository when `true` (tests / UI demos).
///
/// Pass `--dart-define=USE_MOCK_SPLASH=true` to enable.
const bool kUseMockSplashRepository = bool.fromEnvironment(
  'USE_MOCK_SPLASH',
  defaultValue: false,
);

final splashRepositoryProvider = Provider<SplashRepository>((ref) {
  if (kUseMockSplashRepository) {
    return MockSplashRepository();
  }

  return RemoteSplashRepository(
    api: ref.watch(apiClientProvider),
    storage: ref.watch(secureStorageServiceProvider),
  );
});

final splashStatisticsProvider = FutureProvider<List<SplashStatistic>>((ref) {
  return ref.watch(splashRepositoryProvider).fetchStatistics();
});

final splashControllerProvider =
    NotifierProvider<SplashController, SplashState>(SplashController.new);

class SplashController extends Notifier<SplashState> {
  var _inFlight = false;

  @override
  SplashState build() => const SplashState.initial();

  Future<void> bootstrap() async {
    if (_inFlight) return;
    _inFlight = true;
    state = const SplashState.loading();

    final repository = ref.read(splashRepositoryProvider);
    final startedAt = DateTime.now();

    try {
      final result = await repository.bootstrap();
      await _awaitMinimumDuration(startedAt, repository.minimumDisplayDuration);
      _applySession(result);

      // Returning users skip the Statistics marketing intro.
      if (result.hasSeenOnboarding) {
        state = const SplashState.ready(autoContinue: true);
      } else {
        state = const SplashState.intro();
      }
    } catch (error) {
      await _awaitMinimumDuration(startedAt, repository.minimumDisplayDuration);
      // Fail open: show Statistics intro so the user can continue.
      _applySession(
        const SplashBootstrapResult(
          isAuthenticated: false,
          hasSeenOnboarding: false,
        ),
      );
      state = SplashState.failure(error.toString());
    } finally {
      _inFlight = false;
    }
  }

  Future<void> retry() => bootstrap();

  /// CTA from Statistics intro → hand off to GoRouter destination.
  void continueFromIntro() {
    state = const SplashState.ready(autoContinue: true);
  }

  void _applySession(SplashBootstrapResult result) {
    final session = ref.read(authSessionProvider.notifier);
    if (result.isAuthenticated) {
      session.markAuthenticated(hasSeenOnboarding: result.hasSeenOnboarding);
    } else {
      session.markUnauthenticated(hasSeenOnboarding: result.hasSeenOnboarding);
    }
  }

  Future<void> _awaitMinimumDuration(
    DateTime startedAt,
    Duration minimum,
  ) async {
    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed >= minimum) return;
    await Future<void>.delayed(minimum - elapsed);
  }
}
