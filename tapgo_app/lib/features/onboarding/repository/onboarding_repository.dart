import '../models/onboarding_page_data.dart';

/// Contract for loading onboarding slides and persisting completion.
abstract class OnboardingRepository {
  /// Returns ordered onboarding slides.
  Future<List<OnboardingPageData>> fetchPages();

  /// Persists that the user finished / skipped onboarding.
  Future<void> completeOnboarding();
}
