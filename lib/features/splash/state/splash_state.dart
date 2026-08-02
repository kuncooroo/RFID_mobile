/// Splash presentation state.
enum SplashStatus { initial, loading, ready, failure }

class SplashState {
  const SplashState({this.status = SplashStatus.initial, this.errorMessage});

  const SplashState.initial() : this();

  const SplashState.loading() : this(status: SplashStatus.loading);

  const SplashState.ready() : this(status: SplashStatus.ready);

  const SplashState.failure(String message)
    : this(status: SplashStatus.failure, errorMessage: message);

  final SplashStatus status;
  final String? errorMessage;

  bool get isLoading =>
      status == SplashStatus.initial || status == SplashStatus.loading;

  bool get hasFailed => status == SplashStatus.failure;

  SplashState copyWith({SplashStatus? status, String? errorMessage}) {
    return SplashState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
