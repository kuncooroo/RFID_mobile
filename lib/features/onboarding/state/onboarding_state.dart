import '../models/onboarding_page_data.dart';

/// Onboarding presentation / completion state.
enum OnboardingStatus {
  initial,
  loading,
  ready,
  completing,
  completed,
  failure,
}

class OnboardingState {
  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.pages = const [],
    this.currentIndex = 0,
    this.errorMessage,
  });

  const OnboardingState.initial() : this();

  final OnboardingStatus status;
  final List<OnboardingPageData> pages;
  final int currentIndex;
  final String? errorMessage;

  bool get isLoading =>
      status == OnboardingStatus.initial || status == OnboardingStatus.loading;

  bool get isCompleting => status == OnboardingStatus.completing;

  bool get hasFailed => status == OnboardingStatus.failure;

  bool get isLastPage => pages.isNotEmpty && currentIndex >= pages.length - 1;

  int get pageCount => pages.length;

  OnboardingPageData? get currentPage =>
      pages.isEmpty ? null : pages[currentIndex.clamp(0, pages.length - 1)];

  OnboardingState copyWith({
    OnboardingStatus? status,
    List<OnboardingPageData>? pages,
    int? currentIndex,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      pages: pages ?? this.pages,
      currentIndex: currentIndex ?? this.currentIndex,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
