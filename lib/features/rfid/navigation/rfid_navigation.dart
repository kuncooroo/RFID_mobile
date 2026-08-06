import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';

/// RFID feature navigation helpers.
abstract final class RfidNavigation {
  static void openScan(BuildContext context) {
    context.push(AppRoutes.rfidScan);
  }

  static void pop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  static void goHome(BuildContext context) {
    context.go(AppRoutes.home);
  }
}
