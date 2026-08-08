import 'package:flutter/material.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../catalog/models/category.dart';

class HomeCategoryStrip extends StatelessWidget {
  const HomeCategoryStrip({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<Category> onSelected;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected =
              selectedCategoryId == category.id ||
              (selectedCategoryId == null && category.id == 'cat-all');
          return AppChip(
            label: category.name,
            selected: selected,
            onTap: () => onSelected(category),
          );
        },
      ),
    );
  }
}
