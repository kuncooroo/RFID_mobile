import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../product/models/product.dart';
import '../models/favorite.dart';

/// Favorites feature navigation helpers.
abstract final class FavoritesNavigation {
  static void goToFavorites(BuildContext context) {
    context.go(AppRoutes.favorites);
  }

  static void openHome(BuildContext context) {
    context.go(AppRoutes.home);
  }

  static void openProduct(BuildContext context, Product product) {
    context.push(AppRoutes.productDetailPath(product.id));
  }

  static void openFavoriteProduct(BuildContext context, Favorite favorite) {
    final product = favorite.product;
    if (product != null) {
      openProduct(context, product);
      return;
    }
    context.push(AppRoutes.productDetailPath(favorite.productId));
  }

  static void openSearch(BuildContext context) {
    context.push(AppRoutes.search);
  }

  static void openCart(BuildContext context) {
    context.push(AppRoutes.cart);
  }

  static void openNotifications(BuildContext context) {
    context.push(AppRoutes.notifications);
  }
}
