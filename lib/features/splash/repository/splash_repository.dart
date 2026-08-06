import '../models/splash_bootstrap_result.dart';
import '../models/splash_statistic.dart';

/// Contract for restoring local session / onboarding during splash.
abstract class SplashRepository {
  /// Minimum time the branded splash loader should remain visible.
  Duration get minimumDisplayDuration;

  /// Reads tokens / flags and returns the bootstrap decision.
  Future<SplashBootstrapResult> bootstrap();

  /// Marketing stats for the Statistics intro screen.
  Future<List<SplashStatistic>> fetchStatistics();
}
