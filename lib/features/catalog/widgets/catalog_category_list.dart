import 'package:flutter/material.dart';

import '../../../shared/design_system/spacing.dart';
import '../models/category.dart';
import 'catalog_category_banner.dart';

/// Vertical list of alternating Kutuku category banners.
class CatalogCategoryList extends StatelessWidget {
  const CatalogCategoryList({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    this.padding,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  final List<Category> categories;
  final ValueChanged<Category> onCategoryTap;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding:
          padding ??
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.listItem),
      itemBuilder: (context, index) {
        final category = categories[index];
        return CatalogCategoryBanner(
          category: category,
          imageOnRight: index.isEven,
          onTap: () => onCategoryTap(category),
        );
      },
    );
  }
}
