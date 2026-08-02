import '../models/splash_bootstrap_result.dart';

/// Contract for restoring local session / onboarding during splash.
abstract class SplashRepository {
  /// Minimum time the splash branding should remain visible.
  Duration get minimumDisplayDuration;

  /// Reads tokens / flags and returns the bootstrap decision.
  Future<SplashBootstrapResult> bootstrap();
}
