import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../catalog/models/category.dart';
import '../../product/models/product.dart';
import '../models/promotion.dart';
import '../../catalog/navigation/catalog_navigation.dart';

/// Home feature navigation helpers.
abstract final class HomeNavigation {
  static void openSearch(BuildContext context) {
    context.push(AppRoutes.search);
  }

  static void openNotifications(BuildContext context) {
    context.push(AppRoutes.notifications);
  }

  static void openCart(BuildContext context) {
    context.push(AppRoutes.cart);
  }

  static void openCategory(BuildContext context, Category category) {
    CatalogNavigation.openCategory(context, categoryId: category.id);
  }

  static void openProduct(BuildContext context, Product product) {
    context.push(AppRoutes.productDetailPath(product.id));
  }

  static void openPromotion(BuildContext context, Promotion promotion) {
    if (promotion.productId != null && promotion.productId!.isNotEmpty) {
      context.push(AppRoutes.productDetailPath(promotion.productId!));
      return;
    }
    if (promotion.storeId != null && promotion.storeId!.isNotEmpty) {
      context.push(AppRoutes.storeDetailPath(promotion.storeId!));
      return;
    }
    context.push(AppRoutes.search);
  }

  static void openSeeAllNewArrivals(BuildContext context) {
    CatalogNavigation.openCategory(context);
  }
}
