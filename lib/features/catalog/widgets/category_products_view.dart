import 'package:flutter/material.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../product/models/product.dart';
import '../state/catalog_state.dart';
import 'catalog_product_grid.dart';

/// Product listing body for a selected category.
class CategoryProductsView extends StatelessWidget {
  const CategoryProductsView({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onRetry,
    required this.onProductTap,
    required this.onFavoriteTap,
  });

  final CatalogState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<Product> onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.products.isEmpty) {
      return const AppLoading.page(message: 'Loading products…');
    }

    if (state.hasFailed && state.products.isEmpty) {
      return AppErrorState(
        title: 'Could not load category',
        message: state.errorMessage ?? 'Please try again.',
        onRetry: onRetry,
      );
    }

    if (state.products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
        child: AppEmptyState(
          title: 'No products in this category',
          message: 'Try browsing another category or search for items.',
          icon: Icons.category_outlined,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: AppSpacing.lg,
          bottom: AppSpacing.xxxl,
        ),
        children: [
          CatalogProductGrid(
            products: state.products,
            onProductTap: onProductTap,
            onFavoriteTap: onFavoriteTap,
          ),
        ],
      ),
    );
  }
}
