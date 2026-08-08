import 'package:flutter/material.dart';

import '../../../shared/design_system/app_assets.dart';
import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/utils/money.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_image.dart';
import '../../cart/models/cart.dart';

/// Order lines + totals shown on the Payment screen.
class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.items,
    required this.subtotal,
    this.shipping = 0,
    this.discount = 0,
  });

  final List<CartItem> items;
  final double subtotal;
  final double shipping;
  final double discount;

  double get total => subtotal + shipping - discount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.outlined,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          ...items.map(_buildItemRow),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.md),
          _buildSummaryRow('Subtotal', subtotal),
          if (shipping > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildSummaryRow('Shipping', shipping),
          ],
          if (discount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildSummaryRow('Discount', -discount, isDiscount: true),
          ],
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text('Total', style: AppTextStyles.titleMedium),
              ),
              Text(formatMoney(total), style: AppTextStyles.priceLarge),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(CartItem item) {
    final hasNetworkImage =
        item.imageUrl != null && item.imageUrl!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          AppImage(
            imageUrl: hasNetworkImage ? item.imageUrl : null,
            assetPath: hasNetworkImage ? null : AppAssets.placeholderProduct,
            width: 48,
            height: 48,
            borderRadius: AppRadius.smAll,
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
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Qty ${item.quantity}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(formatMoney(item.lineTotal), style: AppTextStyles.price),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isDiscount = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          '${isDiscount ? '-' : ''}${formatMoney(amount.abs())}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDiscount ? AppColors.success : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
