import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/router/auth_session.dart';
import '../../../src/storage/secure_storage_service.dart';
import '../repository/local_onboarding_repository.dart';
import '../repository/mock_onboarding_repository.dart';
import '../repository/onboarding_repository.dart';
import '../state/onboarding_state.dart';

/// Use mock repository when `true` (tests / UI demos).
///
/// Pass `--dart-define=USE_MOCK_ONBOARDING=true` to enable.
const bool kUseMockOnboardingRepository = bool.fromEnvironment(
  'USE_MOCK_ONBOARDING',
  defaultValue: false,
);

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  if (kUseMockOnboardingRepository) {
    return MockOnboardingRepository();
  }

  return LocalOnboardingRepository(
    storage: ref.watch(secureStorageServiceProvider),
  );
});

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState.initial();

  Future<void> load() async {
    if (state.status == OnboardingStatus.loading ||
        state.status == OnboardingStatus.ready) {
      return;
    }

    state = state.copyWith(status: OnboardingStatus.loading, clearError: true);

    try {
      final pages = await ref.read(onboardingRepositoryProvider).fetchPages();
      state = state.copyWith(
        status: OnboardingStatus.ready,
        pages: pages,
        currentIndex: 0,
      );
    } catch (error) {
      state = state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  void setPageIndex(int index) {
    if (state.pages.isEmpty) return;
    final clamped = index.clamp(0, state.pages.length - 1);
    if (clamped == state.currentIndex) return;
    state = state.copyWith(currentIndex: clamped);
  }

  void nextPage() {
    if (state.isLastPage) return;
    setPageIndex(state.currentIndex + 1);
  }

  /// Marks onboarding done and routes via [authSessionProvider] redirect.
  Future<void> complete({required String authEntryRoute}) async {
    if (state.isCompleting) return;

    state = state.copyWith(
      status: OnboardingStatus.completing,
      clearError: true,
    );

    try {
      await ref.read(onboardingRepositoryProvider).completeOnboarding();
      ref
          .read(authSessionProvider.notifier)
          .markOnboardingComplete(authEntryRoute: authEntryRoute);
      state = state.copyWith(status: OnboardingStatus.completed);
    } catch (error) {
      state = state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> createAccount() => complete(authEntryRoute: AppRoutes.register);

  Future<void> signIn() => complete(authEntryRoute: AppRoutes.login);

  Future<void> retry() async {
    state = const OnboardingState.initial();
    await load();
  }
}
