import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_image.dart';
import '../models/category.dart';

/// Alternating category banner from Kutuku Homescreen — Category.
class CatalogCategoryBanner extends StatelessWidget {
  const CatalogCategoryBanner({
    super.key,
    required this.category,
    required this.imageOnRight,
    this.onTap,
  });

  final Category category;
  final bool imageOnRight;
  final VoidCallback? onTap;

  static const double height = 128;

  @override
  Widget build(BuildContext context) {
    final textBlock = Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.name,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _productCountLabel(category.productCount),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );

    final imageBlock = SizedBox(
      width: 148,
      height: height,
      child: category.imageUrl == null || category.imageUrl!.isEmpty
          ? const ColoredBox(color: AppColors.surfaceMuted)
          : AppImage(
              imageUrl: category.imageUrl,
              width: 148,
              height: height,
              borderRadius: BorderRadius.zero,
              fit: BoxFit.cover,
            ),
    );

    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: AppRadius.xlAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Row(
            children: imageOnRight
                ? [textBlock, imageBlock]
                : [imageBlock, textBlock],
          ),
        ),
      ),
    );
  }

  String _productCountLabel(int count) {
    if (count <= 0) return '0 Product';
    return '$count Product';
  }
}
