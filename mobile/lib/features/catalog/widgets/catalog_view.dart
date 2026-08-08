import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../models/category.dart';
import '../providers/catalog_providers.dart';
import '../state/catalog_state.dart';
import 'catalog_category_list.dart';

/// Homescreen Category tab body — banner list from Figma node 1:21.
class CatalogView extends ConsumerStatefulWidget {
  const CatalogView({
    super.key,
    required this.onCategoryTap,
    this.padding = EdgeInsets.zero,
  });

  final ValueChanged<Category> onCategoryTap;
  final EdgeInsetsGeometry padding;

  @override
  ConsumerState<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends ConsumerState<CatalogView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(catalogControllerProvider);
      if (state.feed.isEmpty) {
        ref.read(catalogControllerProvider.notifier).loadCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogControllerProvider);
    final controller = ref.read(catalogControllerProvider.notifier);

    return RefreshIndicator(
      onRefresh: controller.refreshCategories,
      child: _buildBody(state, controller),
    );
  }

  Widget _buildBody(CatalogState state, CatalogController controller) {
    if (state.isLoading && state.feed.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          AppLoading.page(message: 'Loading categories…'),
        ],
      );
    }

    if (state.hasFailed && state.feed.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 320,
            child: AppErrorState(
              title: 'Could not load categories',
              message: state.errorMessage ?? 'Please try again.',
              onRetry: controller.loadCategories,
            ),
          ),
        ],
      );
    }

    if (state.categories.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 80),
          AppEmptyState(
            title: 'No categories yet',
            message: 'Categories will show up here soon.',
            icon: Icons.category_outlined,
          ),
        ],
      );
    }

    return CatalogCategoryList(
      categories: state.categories,
      onCategoryTap: widget.onCategoryTap,
      shrinkWrap: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        left: AppSpacing.screenHorizontal,
        right: AppSpacing.screenHorizontal,
        top: widget.padding.resolve(TextDirection.ltr).top,
        bottom:
            widget.padding.resolve(TextDirection.ltr).bottom + AppSpacing.xxxl,
      ),
    );
  }
}
