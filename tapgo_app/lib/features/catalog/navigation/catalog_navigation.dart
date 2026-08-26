import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../product/models/product.dart';
import '../models/category.dart';

/// Catalog feature navigation helpers.
abstract final class CatalogNavigation {
  static void openCategory(
    BuildContext context, {
    String? categoryId,
    Category? category,
  }) {
    final id = categoryId ?? category?.id;
    final path = id == null || id.isEmpty
        ? AppRoutes.category
        : '${AppRoutes.category}?id=$id';
    context.push(path);
  }

  static void openProduct(BuildContext context, Product product) {
    context.push(AppRoutes.productDetailPath(product.id));
  }

  static void openSearch(BuildContext context) {
    context.push(AppRoutes.search);
  }

  static void pop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }
}
