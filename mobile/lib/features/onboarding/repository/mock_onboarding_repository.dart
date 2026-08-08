import '../models/onboarding_page_data.dart';
import 'onboarding_repository.dart';

/// In-memory onboarding repository for tests and UI demos.
class MockOnboardingRepository implements OnboardingRepository {
  MockOnboardingRepository({
    this.pages = OnboardingPages.defaults,
    this.delay = const Duration(milliseconds: 200),
    this.shouldThrowOnFetch = false,
    this.shouldThrowOnComplete = false,
    this.fetchErrorMessage = 'Mock onboarding fetch failed',
    this.completeErrorMessage = 'Mock onboarding complete failed',
  });

  final List<OnboardingPageData> pages;
  final Duration delay;
  final bool shouldThrowOnFetch;
  final bool shouldThrowOnComplete;
  final String fetchErrorMessage;
  final String completeErrorMessage;

  var completed = false;

  @override
  Future<List<OnboardingPageData>> fetchPages() async {
    await Future<void>.delayed(delay);
    if (shouldThrowOnFetch) {
      throw StateError(fetchErrorMessage);
    }
    return List<OnboardingPageData>.unmodifiable(pages);
  }

  @override
  Future<void> completeOnboarding() async {
    await Future<void>.delayed(delay);
    if (shouldThrowOnComplete) {
      throw StateError(completeErrorMessage);
    }
    completed = true;
  }
}
