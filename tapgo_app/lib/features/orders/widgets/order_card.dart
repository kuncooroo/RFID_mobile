import 'package:flutter/material.dart';

import '../../../shared/design_system/app_assets.dart';
import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/utils/money.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_image.dart';
import '../models/history.dart';
import '../models/order.dart';
import 'order_item_row.dart';
import 'order_status_chip.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, this.onTrack, this.onTap});

  final Order order;
  final VoidCallback? onTrack;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.orderNumber, style: AppTextStyles.titleMedium),
                    if (order.placedAt != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        _formatDate(order.placedAt!),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              OrderStatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.divider),
          ...order.items.take(2).map((item) => OrderItemRow(item: item)),
          if (order.items.length > 2)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                '+${order.items.length - 2} more item(s)',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total  ${formatMoney(order.total)}',
                  style: AppTextStyles.price,
                ),
              ),
              if (onTrack != null && order.isActive)
                AppButton(
                  label: 'Track Order',
                  onPressed: onTrack,
                  isExpanded: false,
                  height: 40,
                  size: AppButtonSize.small,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }
}

class HistoryOrderCard extends StatelessWidget {
  const HistoryOrderCard({super.key, required this.item, this.onTap});

  final History item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        item.thumbnailUrl != null && item.thumbnailUrl!.trim().isNotEmpty;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          AppImage(
            imageUrl: hasImage ? item.thumbnailUrl : null,
            assetPath: hasImage ? null : AppAssets.placeholderProduct,
            width: 64,
            height: 64,
            borderRadius: AppRadius.mdAll,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.orderNumber, style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${item.itemCount} item(s) · ${formatMoney(item.total)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (item.completedAt != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    _formatDate(item.completedAt!),
                    style: AppTextStyles.labelSmall,
                  ),
                ],
              ],
            ),
          ),
          OrderStatusChip(status: item.status),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }
}
