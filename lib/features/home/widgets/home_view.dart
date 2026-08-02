import 'package:flutter/material.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../catalog/models/category.dart';
import '../../product/models/product.dart';
import '../navigation/home_navigation.dart';
import '../state/home_state.dart';
import 'home_category_strip.dart';
import 'home_product_grid.dart';
import 'home_promo_section.dart';
import 'home_segment_tabs.dart';

/// Scrollable Home body for Home / Category segments.
class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onRetry,
    required this.onSegmentChanged,
    required this.onCategorySelected,
    required this.onFavoriteTap,
    this.onSearchTap,
  });

  final HomeState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final ValueChanged<HomeSegment> onSegmentChanged;
  final ValueChanged<Category> onCategorySelected;
  final ValueChanged<Product> onFavoriteTap;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.feed.isEmpty) {
      return const AppLoading.page(message: 'Loading home…');
    }

    if (state.hasFailed && state.feed.isEmpty) {
      return AppErrorState(
        title: 'Could not load home',
        message: state.errorMessage ?? 'Please try again.',
        onRetry: onRetry,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.md,
            ),
            child: AppSearchBar(
              hintText: 'Search clothes, shoes, accessories…',
              readOnly: true,
              onTap: onSearchTap ?? () => HomeNavigation.openSearch(context),
            ),
          ),
          HomeSegmentTabs(segment: state.segment, onChanged: onSegmentChanged),
          const SizedBox(height: AppSpacing.xl),
          if (state.segment == HomeSegment.home) ...[
            HomePromoSection(
              promotions: state.feed.promotions,
              onPromotionTap: (promo) =>
                  HomeNavigation.openPromotion(context, promo),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppSectionHeader(
              title: 'New Arrivals',
              actionLabel: 'See All',
              onAction: () => HomeNavigation.openSeeAllNewArrivals(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ProductSection(
              products: state.visibleProducts,
              emptyTitle: 'No products yet',
              emptyMessage: 'New arrivals will show up here soon.',
              emptyIcon: Icons.shopping_bag_outlined,
              onFavoriteTap: onFavoriteTap,
            ),
          ] else ...[
            HomeCategoryStrip(
              categories: state.feed.categories,
              selectedCategoryId: state.selectedCategoryId,
              onSelected: onCategorySelected,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppSectionHeader(
              title: _categoryTitle(state),
              actionLabel: 'See All',
              onAction: () => HomeNavigation.openSeeAllNewArrivals(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ProductSection(
              products: state.visibleProducts,
              emptyTitle: 'No items in this category',
              emptyMessage: 'Try another category to keep browsing.',
              emptyIcon: Icons.category_outlined,
              onFavoriteTap: onFavoriteTap,
            ),
          ],
        ],
      ),
    );
  }

  String _categoryTitle(HomeState state) {
    final id = state.selectedCategoryId;
    if (id == null || id == 'cat-all') return 'All Products';
    for (final category in state.feed.categories) {
      if (category.id == id) return category.name;
    }
    return 'Products';
  }
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({
    required this.products,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.onFavoriteTap,
  });

  final List<Product> products;
  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;
  final ValueChanged<Product> onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
        child: AppEmptyState(
          title: emptyTitle,
          message: emptyMessage,
          icon: emptyIcon,
        ),
      );
    }

    return HomeProductGrid(
      products: products,
      onProductTap: (product) => HomeNavigation.openProduct(context, product),
      onFavoriteTap: onFavoriteTap,
    );
  }
}
