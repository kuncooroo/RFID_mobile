import 'package:flutter/material.dart';

import '../../../shared/design_system/app_assets.dart';
import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/utils/money.dart';
import '../../../shared/widgets/app_image.dart';
import '../../../shared/widgets/app_qty_stepper.dart';
import '../models/cart.dart';

/// Selectable cart line item (My Cart / Selected / v2).
class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.onToggleSelect,
    required this.onQtyChanged,
    this.onTap,
    this.onDelete,
  });

  final CartItem item;
  final VoidCallback onToggleSelect;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage =
        item.imageUrl != null && item.imageUrl!.trim().isNotEmpty;
    final variantParts = <String>[
      if (item.colorName != null && item.colorName!.isNotEmpty) item.colorName!,
      if (item.size != null && item.size!.isNotEmpty) 'Size ${item.size}',
    ];

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: item.isSelected,
              onChanged: (_) => onToggleSelect(),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.xsAll),
            ),
            AppImage(
              imageUrl: hasNetworkImage ? item.imageUrl : null,
              assetPath: hasNetworkImage ? null : AppAssets.placeholderProduct,
              width: 80,
              height: 80,
              borderRadius: AppRadius.mdAll,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.brand != null && item.brand!.isNotEmpty) ...[
                    Text(
                      item.brand!,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                  ],
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall,
                  ),
                  if (variantParts.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      variantParts.join(' · '),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        formatMoney(item.unitPrice),
                        style: AppTextStyles.price,
                      ),
                      const Spacer(),
                      AppQtyStepper(
                        value: item.quantity,
                        max: item.maxQuantity,
                        onChanged: onQtyChanged,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                tooltip: 'Remove',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                color: AppColors.textSecondary,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
