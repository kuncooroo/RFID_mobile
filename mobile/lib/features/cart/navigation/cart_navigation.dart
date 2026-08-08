import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';

/// Cart feature navigation helpers.
abstract final class CartNavigation {
  static void openCheckout(BuildContext context) {
    context.push(AppRoutes.checkoutAddress);
  }

  static void openProduct(BuildContext context, String productId) {
    context.push(AppRoutes.productDetailPath(productId));
  }

  static void pop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }

  static void openHome(BuildContext context) {
    context.go(AppRoutes.home);
  }
}
