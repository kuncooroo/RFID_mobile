import 'package:flutter/material.dart';

import '../../../shared/design_system/app_assets.dart';
import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_image.dart';
import '../models/order.dart';

class OrderItemRow extends StatelessWidget {
  const OrderItemRow({super.key, required this.item, this.onTap});

  final OrderItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage =
        item.imageUrl != null && item.imageUrl!.trim().isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            AppImage(
              imageUrl: hasNetworkImage ? item.imageUrl : null,
              assetPath: hasNetworkImage ? null : AppAssets.placeholderProduct,
              width: 56,
              height: 56,
              borderRadius: AppRadius.mdAll,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall,
                  ),
                  if (item.variantLabel != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      item.variantLabel!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxs),
                  Text('Qty ${item.quantity}', style: AppTextStyles.labelSmall),
                ],
              ),
            ),
            Text(
              '\$${item.lineTotal.toStringAsFixed(0)}',
              style: AppTextStyles.price,
            ),
          ],
        ),
      ),
    );
  }
}
