/// Splash presentation state.
enum SplashStatus { initial, loading, intro, ready, failure }

class SplashState {
  const SplashState({
    this.status = SplashStatus.initial,
    this.errorMessage,
    this.autoContinue = false,
  });

  const SplashState.initial() : this();

  const SplashState.loading() : this(status: SplashStatus.loading);

  const SplashState.intro() : this(status: SplashStatus.intro);

  const SplashState.ready({bool autoContinue = false})
      : this(status: SplashStatus.ready, autoContinue: autoContinue);

  const SplashState.failure(String message)
      : this(status: SplashStatus.failure, errorMessage: message);

  final SplashStatus status;
  final String? errorMessage;

  /// When true, splash should navigate away without waiting for a CTA.
  final bool autoContinue;

  bool get isLoading =>
      status == SplashStatus.initial || status == SplashStatus.loading;

  bool get showIntro => status == SplashStatus.intro;

  bool get hasFailed => status == SplashStatus.failure;

  bool get shouldAutoNavigate =>
      status == SplashStatus.ready && autoContinue;

  SplashState copyWith({
    SplashStatus? status,
    String? errorMessage,
    bool? autoContinue,
    bool clearError = false,
  }) {
    return SplashState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      autoContinue: autoContinue ?? this.autoContinue,
    );
  }
}
