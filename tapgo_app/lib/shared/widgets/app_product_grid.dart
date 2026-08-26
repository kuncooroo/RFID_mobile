import 'package:flutter/material.dart';

import '../design_system/sizes.dart';
import '../design_system/spacing.dart';

/// Shared 2-column product grid chrome used across Home, Search, Store,
/// Catalog, and Favorites. Feature layers supply the card builder.
class AppProductGrid extends StatelessWidget {
  const AppProductGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.screenHorizontal,
    ),
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 0) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: GridView.builder(
        shrinkWrap: shrinkWrap,
        physics: physics,
        itemCount: itemCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppSizes.productGridCrossAxisCount,
          mainAxisSpacing: AppSpacing.grid,
          crossAxisSpacing: AppSpacing.grid,
          childAspectRatio: AppSizes.productGridAspectRatio,
        ),
        itemBuilder: itemBuilder,
      ),
    );
  }
}
