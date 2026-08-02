import '../../../features/auth/models/user.dart';

/// Result of splash bootstrap (session + onboarding flags).
class SplashBootstrapResult {
  const SplashBootstrapResult({
    required this.isAuthenticated,
    required this.hasSeenOnboarding,
    this.user,
    this.accessToken,
  });

  final bool isAuthenticated;
  final bool hasSeenOnboarding;
  final User? user;
  final String? accessToken;

  SplashBootstrapResult copyWith({
    bool? isAuthenticated,
    bool? hasSeenOnboarding,
    User? user,
    String? accessToken,
  }) {
    return SplashBootstrapResult(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
    );
  }
}
