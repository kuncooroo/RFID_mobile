import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';

/// My Profile / Settings navigation helpers.
abstract final class ProfileNavigation {
  static void goToProfile(BuildContext context) {
    context.go(AppRoutes.profile);
  }

  static void pop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.profile);
    }
  }

  static void openSettings(BuildContext context) {
    context.push(AppRoutes.settings);
  }

  static void openEditProfile(BuildContext context) {
    context.push(AppRoutes.editProfile);
  }

  static void openChangePassword(BuildContext context) {
    context.push(AppRoutes.changePassword);
  }

  static void openNotificationSettings(BuildContext context) {
    context.push(AppRoutes.notificationSettings);
  }

  static void openSecurity(BuildContext context) {
    context.push(AppRoutes.security);
  }

  static void openLanguage(BuildContext context) {
    context.push(AppRoutes.language);
  }

  static void openHelpSupport(BuildContext context) {
    context.push(AppRoutes.helpSupport);
  }

  static void openLegalPolicies(BuildContext context) {
    context.push(AppRoutes.legalPolicies);
  }

  static void openNotifications(BuildContext context) {
    context.push(AppRoutes.notifications);
  }

  static void openMessages(BuildContext context) {
    context.push(AppRoutes.messages);
  }

  static void openOrders(BuildContext context) {
    context.go(AppRoutes.orders);
  }

  static void openFavorites(BuildContext context) {
    context.go(AppRoutes.favorites);
  }

  static void openLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }
}
