import '../models/splash_bootstrap_result.dart';
import 'splash_repository.dart';

/// In-memory splash repository for tests and local UI development.
class MockSplashRepository implements SplashRepository {
  MockSplashRepository({
    this.minimumDisplayDuration = const Duration(milliseconds: 1200),
    this.delay = const Duration(milliseconds: 600),
    this.result = const SplashBootstrapResult(
      isAuthenticated: false,
      hasSeenOnboarding: false,
    ),
    this.shouldThrow = false,
    this.errorMessage = 'Mock splash bootstrap failed',
  });

  @override
  final Duration minimumDisplayDuration;

  final Duration delay;
  final SplashBootstrapResult result;
  final bool shouldThrow;
  final String errorMessage;

  @override
  Future<SplashBootstrapResult> bootstrap() async {
    await Future<void>.delayed(delay);
    if (shouldThrow) {
      throw StateError(errorMessage);
    }
    return result;
  }
}
