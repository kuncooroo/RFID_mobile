import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../product/models/product.dart';

/// Catalog feature navigation helpers.
abstract final class CatalogNavigation {
  static void openCategory(
    BuildContext context, {
    String? categoryId,
  }) {
    final path = categoryId == null || categoryId.isEmpty
        ? AppRoutes.category
        : '${AppRoutes.category}?id=$categoryId';
    context.push(path);
  }

  static void openProduct(BuildContext context, Product product) {
    context.push(AppRoutes.productDetailPath(product.id));
  }

  static void pop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }
}
