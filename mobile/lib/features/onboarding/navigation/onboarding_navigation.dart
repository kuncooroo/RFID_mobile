import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/router/auth_session.dart';

/// Onboarding navigation helpers.
///
/// Prefer completing via [authSessionProvider] so GoRouter redirects.
/// Explicit helpers remain for tests and fallbacks.
abstract final class OnboardingNavigation {
  static String resolveDestination(AuthSessionState session) {
    if (session.isAuthenticated) return AppRoutes.dashboard;
    return session.authEntryRoute ?? AppRoutes.login;
  }

  static void goToAuthEntry(BuildContext context, AuthSessionState session) {
    final target = resolveDestination(session);
    if (GoRouterState.of(context).matchedLocation == target) return;
    context.go(target);
  }

  static void goToRegister(BuildContext context) {
    context.go(AppRoutes.register);
  }

  static void goToLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }
}
