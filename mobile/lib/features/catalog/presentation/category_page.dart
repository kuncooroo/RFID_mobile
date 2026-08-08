import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/text_styles.dart';
import '../navigation/catalog_navigation.dart';
import '../providers/catalog_providers.dart';
import '../widgets/category_products_view.dart';

/// Category product listing opened from Homescreen Category banners.
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
      ref
          .read(catalogControllerProvider.notifier)
          .loadProducts(categoryId: widget.categoryId);
    });
  }

  @override
  void didUpdateWidget(covariant CategoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId) {
      ref
          .read(catalogControllerProvider.notifier)
          .loadProducts(categoryId: widget.categoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogControllerProvider);
    final controller = ref.read(catalogControllerProvider.notifier);

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
        title: Text(state.title, style: AppTextStyles.headlineSmall),
        centerTitle: false,
      ),
      body: CategoryProductsView(
        state: state,
        onRefresh: controller.refreshProducts,
        onRetry: () =>
            controller.loadProducts(categoryId: widget.categoryId),
        onProductTap: (product) =>
            CatalogNavigation.openProduct(context, product),
        onFavoriteTap: controller.toggleFavorite,
      ),
    );
  }
}
