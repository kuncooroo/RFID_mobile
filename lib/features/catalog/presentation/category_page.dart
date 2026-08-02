import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../home/providers/home_providers.dart';
import '../../home/state/home_state.dart';
import '../../home/widgets/home_product_grid.dart';
import '../../product/models/product.dart';
import '../navigation/catalog_navigation.dart';

/// Category browse screen showing products from the home feed.
class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key, this.categoryId});

  final String? categoryId;

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final homeState = ref.read(homeControllerProvider);
      if (homeState.feed.isEmpty) {
        ref.read(homeControllerProvider.notifier).load();
      }
    });
  }

  List<Product> _visibleProducts(HomeState homeState) {
    final products = homeState.feed.categoryProducts;
    final categoryId = widget.categoryId;
    if (categoryId == null || categoryId.isEmpty || categoryId == 'cat-all') {
      return products;
    }
    return products.where((p) => p.categoryId == categoryId).toList();
  }

  String _title(HomeState homeState) {
    final categoryId = widget.categoryId;
    if (categoryId == null || categoryId.isEmpty || categoryId == 'cat-all') {
      return 'Category';
    }
    for (final category in homeState.feed.categories) {
      if (category.id == categoryId) return category.name;
    }
    return 'Category';
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);
    final products = _visibleProducts(homeState);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => CatalogNavigation.pop(context),
        ),
        title: Text(_title(homeState), style: AppTextStyles.headlineSmall),
        centerTitle: false,
      ),
      body: _buildBody(homeState, products, controller),
    );
  }

  Widget _buildBody(
    HomeState homeState,
    List<Product> products,
    HomeController controller,
  ) {
    if (homeState.isLoading && homeState.feed.isEmpty) {
      return const AppLoading.page(message: 'Loading products…');
    }

    if (homeState.hasFailed && homeState.feed.isEmpty) {
      return AppErrorState(
        title: 'Could not load category',
        message: homeState.errorMessage ?? 'Please try again.',
        onRetry: controller.load,
      );
    }

    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
        child: AppEmptyState(
          title: 'No products in this category',
          message: 'Try browsing another category or search for items.',
          icon: Icons.category_outlined,
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.xxxl,
      ),
      children: [
        HomeProductGrid(
          products: products,
          onProductTap: (product) =>
              CatalogNavigation.openProduct(context, product),
          onFavoriteTap: controller.toggleFavorite,
        ),
      ],
    );
  }
}
