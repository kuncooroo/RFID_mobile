import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/router/auth_session.dart';

/// Splash / Statistics navigation helpers.
///
/// Prefer updating [authSessionProvider] and navigating explicitly from splash
/// after bootstrap or the Get Started CTA.
abstract final class SplashNavigation {
  static String resolveDestination(AuthSessionState session) {
    if (!session.hasSeenOnboarding) return AppRoutes.onboarding;
    if (session.isAuthenticated) return AppRoutes.dashboard;
    return session.authEntryRoute ?? AppRoutes.login;
  }

  static void goToResolvedDestination(
    BuildContext context,
    AuthSessionState session,
  ) {
    final target = resolveDestination(session);
    if (GoRouterState.of(context).matchedLocation == target) return;
    context.go(target);
  }
}
