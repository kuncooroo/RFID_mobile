import '../../../src/storage/secure_storage_service.dart';
import '../models/onboarding_page_data.dart';
import 'onboarding_repository.dart';

/// Production onboarding: static slides + secure-storage completion flag.
class LocalOnboardingRepository implements OnboardingRepository {
  LocalOnboardingRepository({
    required SecureStorageService storage,
    this.pages = OnboardingPages.defaults,
  }) : _storage = storage;

  final SecureStorageService _storage;
  final List<OnboardingPageData> pages;

  @override
  Future<List<OnboardingPageData>> fetchPages() async {
    return List<OnboardingPageData>.unmodifiable(pages);
  }

  @override
  Future<void> completeOnboarding() async {
    await _storage.write(SecureStorageKeys.hasSeenOnboarding, 'true');
  }
}
