import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lightweight auth status used only by route redirects.
enum AuthStatus {
  /// Session is still being restored (e.g. splash).
  unknown,

  /// Valid Sanctum session exists.
  authenticated,

  /// No valid session.
  unauthenticated,
}

class AuthSessionState {
  const AuthSessionState({
    this.status = AuthStatus.unknown,
    this.hasSeenOnboarding = false,
    this.authEntryRoute,
  });

  final AuthStatus status;
  final bool hasSeenOnboarding;

  /// Preferred auth route after onboarding (e.g. login vs register).
  final String? authEntryRoute;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isUnknown => status == AuthStatus.unknown;

  AuthSessionState copyWith({
    AuthStatus? status,
    bool? hasSeenOnboarding,
    String? authEntryRoute,
    bool clearAuthEntryRoute = false,
  }) {
    return AuthSessionState(
      status: status ?? this.status,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      authEntryRoute: clearAuthEntryRoute
          ? null
          : (authEntryRoute ?? this.authEntryRoute),
    );
  }
}

class AuthSessionNotifier extends Notifier<AuthSessionState> {
  @override
  AuthSessionState build() => const AuthSessionState(
    // Splash owns session restore; start unknown so redirect stays on splash.
    status: AuthStatus.unknown,
  );
  void markAuthenticated({bool? hasSeenOnboarding}) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      hasSeenOnboarding: hasSeenOnboarding,
    );
  }

  void markUnauthenticated({bool? hasSeenOnboarding}) {
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      hasSeenOnboarding: hasSeenOnboarding,
    );
  }

  void markOnboardingComplete({String? authEntryRoute}) {
    state = state.copyWith(
      hasSeenOnboarding: true,
      authEntryRoute: authEntryRoute,
    );
  }

  void clearAuthEntryRoute() {
    state = state.copyWith(clearAuthEntryRoute: true);
  }

  void markUnknown() {
    state = state.copyWith(status: AuthStatus.unknown);
  }
}

final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthSessionState>(
      AuthSessionNotifier.new,
    );
