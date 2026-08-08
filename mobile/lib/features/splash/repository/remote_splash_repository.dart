import '../../../src/network/api_client.dart';
import '../../../src/network/api_endpoints.dart';
import '../../../src/network/api_exception.dart';
import '../../../src/storage/secure_storage_service.dart';
import '../models/splash_bootstrap_result.dart';
import '../models/splash_statistic.dart';
import 'splash_repository.dart';

class RemoteSplashRepository implements SplashRepository {
  RemoteSplashRepository({
    required ApiClient api,
    required SecureStorageService storage,
  }) : _api = api,
       _storage = storage;

  final ApiClient _api;
  final SecureStorageService _storage;

  @override
  Duration get minimumDisplayDuration => const Duration(milliseconds: 1500);

  @override
  Future<SplashBootstrapResult> bootstrap() async {
    final hasSeen =
        (await _storage.read(SecureStorageKeys.hasSeenOnboarding)) == 'true';
    final token = await _storage.read(SecureStorageKeys.accessToken);

    if (token == null || token.isEmpty) {
      return SplashBootstrapResult(
        isAuthenticated: false,
        hasSeenOnboarding: hasSeen,
      );
    }

    try {
      await _api.get<dynamic>(ApiEndpoints.user, trackLoading: false);
      return SplashBootstrapResult(
        isAuthenticated: true,
        hasSeenOnboarding: hasSeen,
      );
    } on ApiException catch (e) {
      // Only wipe credentials on confirmed auth failure — keep tokens when offline.
      if (e.isUnauthorized) {
        await _storage.delete(SecureStorageKeys.accessToken);
        await _storage.delete(SecureStorageKeys.refreshToken);
        return SplashBootstrapResult(
          isAuthenticated: false,
          hasSeenOnboarding: hasSeen,
        );
      }

      // Offline / transient server errors: keep tokens and treat as signed-in.
      return SplashBootstrapResult(
        isAuthenticated: true,
        hasSeenOnboarding: hasSeen,
      );
    } catch (_) {
      return SplashBootstrapResult(
        isAuthenticated: true,
        hasSeenOnboarding: hasSeen,
      );
    }
  }

  @override
  Future<List<SplashStatistic>> fetchStatistics() async {
    return const [
      SplashStatistic(label: 'Products', value: '10K+'),
      SplashStatistic(label: 'Brands', value: '500+'),
      SplashStatistic(label: 'Happy Shoppers', value: '1M+'),
    ];
  }
}
