import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../product/models/product.dart';

/// Store feature navigation helpers.
abstract final class StoreNavigation {
  static void pop(BuildContext context) {
    context.pop();
  }

  static void openProduct(BuildContext context, Product product) {
    context.push(AppRoutes.productDetailPath(product.id));
  }

  static void openCart(BuildContext context) {
    context.push(AppRoutes.cart);
  }

  static void openMessages(BuildContext context) {
    context.push(AppRoutes.messages);
  }
}
