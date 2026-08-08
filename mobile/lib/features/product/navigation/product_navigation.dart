import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';

/// Product feature navigation helpers.
abstract final class ProductNavigation {
  static void openProduct(BuildContext context, String productId) {
    context.push(AppRoutes.productDetailPath(productId));
  }

  static void openCart(BuildContext context) {
    context.push(AppRoutes.cart);
  }

  static void openStore(BuildContext context, String storeId) {
    context.push(AppRoutes.storeDetailPath(storeId));
  }

  static void openSearch(BuildContext context) {
    context.push(AppRoutes.search);
  }

  static void openMessages(BuildContext context) {
    context.push(AppRoutes.messages);
  }

  static void pop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }
}
