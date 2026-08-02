import '../../../src/storage/secure_storage_service.dart';
import '../../auth/models/user.dart';
import '../models/splash_bootstrap_result.dart';
import 'splash_repository.dart';

/// Production splash bootstrap using secure storage (no network).
///
/// Token presence marks the session as authenticated. Full user hydration
/// belongs to the auth feature once Sanctum `/user` is available.
class LocalSplashRepository implements SplashRepository {
  LocalSplashRepository({
    required SecureStorageService storage,
    this.minimumDisplayDuration = const Duration(milliseconds: 1500),
  }) : _storage = storage;

  final SecureStorageService _storage;

  @override
  final Duration minimumDisplayDuration;

  @override
  Future<SplashBootstrapResult> bootstrap() async {
    final token = await _storage.read(SecureStorageKeys.accessToken);
    final onboardingRaw = await _storage.read(
      SecureStorageKeys.hasSeenOnboarding,
    );
    final hasSeenOnboarding = onboardingRaw == 'true';
    final hasToken = token != null && token.isNotEmpty;

    return SplashBootstrapResult(
      isAuthenticated: hasToken,
      hasSeenOnboarding: hasSeenOnboarding,
      accessToken: hasToken ? token : null,
      user: hasToken ? User(id: 'local', name: 'Member', email: '') : null,
    );
  }
}
