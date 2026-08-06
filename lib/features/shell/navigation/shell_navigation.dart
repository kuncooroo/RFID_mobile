import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../models/shell_tab.dart';

/// Navigation helpers for the main app shell.
abstract final class ShellNavigation {
  static const tabLocations = <String>[
    AppRoutes.dashboard,
    AppRoutes.orders,
    AppRoutes.favorites,
    AppRoutes.profile,
  ];

  static void goToTab(BuildContext context, ShellTab tab) {
    context.go(tabLocations[tab.branchIndex]);
  }

  static void goToHome(BuildContext context) => goToTab(context, ShellTab.home);

  static void goToOrders(BuildContext context) =>
      goToTab(context, ShellTab.orders);

  static void goToFavorites(BuildContext context) =>
      goToTab(context, ShellTab.favorites);

  static void goToProfile(BuildContext context) =>
      goToTab(context, ShellTab.profile);

  static void openNotifications(BuildContext context) {
    context.push(AppRoutes.notifications);
  }

  static void openCart(BuildContext context) {
    context.push(AppRoutes.cart);
  }

  static void openSearch(BuildContext context) {
    context.push(AppRoutes.search);
  }

  static void openSettings(BuildContext context) {
    context.push(AppRoutes.settings);
  }

  static void openMessages(BuildContext context) {
    context.push(AppRoutes.messages);
  }

  static void openRfidScan(BuildContext context) {
    context.push(AppRoutes.rfidScan);
  }
}

/// Maps shell branch index to its root location.
abstract final class MainShellBranches {
  static const locations = ShellNavigation.tabLocations;
}
