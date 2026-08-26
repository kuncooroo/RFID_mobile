import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';

/// Auth feature navigation helpers.
abstract final class AuthNavigation {
  static void goToLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }

  static void goToRegister(BuildContext context) {
    context.go(AppRoutes.register);
  }

  static void goToRegisterSuccess(BuildContext context) {
    context.go(AppRoutes.registerSuccess);
  }

  static void goToForgotPassword(BuildContext context, {String? identifier}) {
    final uri = Uri(
      path: AppRoutes.forgotPassword,
      queryParameters: {
        if (identifier != null && identifier.trim().isNotEmpty)
          'email': identifier.trim(),
      },
    );
    context.push(uri.toString());
  }

  static void goToResetPassword(
    BuildContext context, {
    String? identifier,
    String? token,
  }) {
    final uri = Uri(
      path: AppRoutes.resetPassword,
      queryParameters: {
        if (identifier != null && identifier.trim().isNotEmpty)
          'email': identifier.trim(),
        if (token != null && token.isNotEmpty) 'token': token,
      },
    );
    context.push(uri.toString());
  }

  static void goToDashboard(BuildContext context) {
    context.go(AppRoutes.dashboard);
  }

  static void popOrLogin(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      goToLogin(context);
    }
  }
}
