import 'package:flutter/material.dart';

import '../design_system/colors.dart';
import '../design_system/sizes.dart';
import '../design_system/spacing.dart';
import '../design_system/text_styles.dart';

/// Star rating label used on Product Detail.
class AppRating extends StatelessWidget {
  const AppRating({
    super.key,
    required this.rating,
    this.reviewCount,
    this.iconSize = AppSizes.iconSm,
  });

  final double rating;
  final int? reviewCount;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: iconSize, color: AppColors.rating),
        const SizedBox(width: AppSpacing.xs),
        Text(rating.toStringAsFixed(1), style: AppTextStyles.titleSmall),
        if (reviewCount != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Text('($reviewCount Review)', style: AppTextStyles.bodySmall),
        ],
      ],
    );
  }
}
