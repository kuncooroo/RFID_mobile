import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../navigation/orders_navigation.dart';
import '../state/orders_state.dart';
import 'order_item_row.dart';
import 'order_status_chip.dart';
import 'order_track_timeline.dart';

class OrderTrackView extends StatelessWidget {
  const OrderTrackView({super.key, required this.state, required this.onRetry});

  final OrderTrackState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const AppLoading.page(message: 'Loading tracking…');
    }

    if (state.hasFailed || state.order == null) {
      return AppErrorState(
        title: 'Could not load tracking',
        message: state.errorMessage ?? 'Order not found.',
        onRetry: onRetry,
      );
    }

    final order = state.order!;
    final tracking = order.tracking;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.orderNumber,
                      style: AppTextStyles.headlineSmall,
                    ),
                  ),
                  OrderStatusChip(status: order.status),
                ],
              ),
              if (tracking?.courierName != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Courier: ${tracking!.courierName}',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
              if (tracking?.trackingNumber != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tracking No: ${tracking!.trackingNumber}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Tracking', style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.lg),
        if (tracking == null)
          Text(
            'Tracking details are not available for this order yet.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          )
        else
          OrderTrackTimeline(events: tracking.events),
        const SizedBox(height: AppSpacing.xxxl),
        Text('Items', style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              for (final item in order.items)
                OrderItemRow(
                  item: item,
                  onTap: () =>
                      OrdersNavigation.openProduct(context, item.productId),
                ),
              const Divider(height: 24, color: AppColors.divider),
              Row(
                children: [
                  Expanded(
                    child: Text('Total', style: AppTextStyles.titleMedium),
                  ),
                  Text(
                    '\$${order.total.toStringAsFixed(0)}',
                    style: AppTextStyles.price,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
