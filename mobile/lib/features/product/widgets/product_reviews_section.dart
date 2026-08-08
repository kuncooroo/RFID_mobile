import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../models/review.dart';

class ProductReviewsSection extends StatelessWidget {
  const ProductReviewsSection({super.key, required this.reviews});

  final List<Review> reviews;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.xxl,
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reviews', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.md),
          if (reviews.isEmpty)
            Text(
              'No reviews yet for this product.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            for (final review in reviews) ...[
              _ReviewTile(review: review),
              const SizedBox(height: AppSpacing.md),
            ],
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.memberName?.trim().isNotEmpty == true
                      ? review.memberName!
                      : 'Buyer',
                  style: AppTextStyles.titleSmall,
                ),
              ),
              Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
              const SizedBox(width: 4),
              Text(
                review.rating.toStringAsFixed(
                  review.rating == review.rating.roundToDouble() ? 0 : 1,
                ),
                style: AppTextStyles.labelMedium,
              ),
            ],
          ),
          if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              review.comment!,
              style: AppTextStyles.bodyMedium.copyWith(height: 1.45),
            ),
          ],
        ],
      ),
    );
  }
}
