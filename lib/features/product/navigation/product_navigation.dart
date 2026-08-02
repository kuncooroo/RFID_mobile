import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';

/// Product feature navigation helpers.
abstract final class ProductNavigation {
  static void pop(BuildContext context) {
    context.pop();
  }

  static void openCart(BuildContext context) {
    context.push(AppRoutes.cart);
  }

  static void openStore(BuildContext context, String storeId) {
    context.push(AppRoutes.storeDetailPath(storeId));
  }

  static void openMessages(BuildContext context) {
    context.push(AppRoutes.messages);
  }
}
