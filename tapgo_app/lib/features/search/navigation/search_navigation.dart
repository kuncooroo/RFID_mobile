import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../product/models/product.dart';
import '../models/search_filter.dart';
import '../widgets/search_filter_sheet.dart';

/// Search feature navigation helpers.
abstract final class SearchNavigation {
  static void openResults(BuildContext context, {required String query}) {
    final encoded = Uri.encodeComponent(query);
    context.push('${AppRoutes.searchResults}?q=$encoded');
  }

  static void openProduct(BuildContext context, Product product) {
    context.push(AppRoutes.productDetailPath(product.id));
  }

  static Future<SearchFilter?> openFilterSheet(
    BuildContext context, {
    required SearchFilter initialFilter,
    required SearchFilterOptions options,
  }) {
    return showAppBottomSheet<SearchFilter>(
      context: context,
      title: 'Filter By',
      child: SearchFilterSheet(
        initialFilter: initialFilter,
        options: options,
      ),
    );
  }

  static void pop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }

  static void openCart(BuildContext context) {
    context.push(AppRoutes.cart);
  }

  static void openSearch(BuildContext context) {
    context.push(AppRoutes.search);
  }
}
