import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/utils/money.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../models/order.dart';
import '../state/orders_state.dart';
import 'order_item_row.dart';
import 'order_status_chip.dart';
import 'order_track_timeline.dart';

class OrderTrackView extends StatelessWidget {
  const OrderTrackView({
    super.key,
    required this.state,
    required this.onRetry,
    this.onRefresh,
    this.onCopyTrackingNumber,
    this.onOpenProduct,
  });

  final OrderTrackState state;
  final VoidCallback onRetry;
  final Future<void> Function()? onRefresh;
  final ValueChanged<String>? onCopyTrackingNumber;
  final ValueChanged<String>? onOpenProduct;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.order == null) {
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
    final content = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        AppSpacing.xxxl,
      ),
      children: [
        _OrderHeaderCard(
          order: order,
          tracking: tracking,
          onCopyTrackingNumber: onCopyTrackingNumber,
        ),
        if (order.shippingAddressLabel != null &&
            order.shippingAddressLabel!.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text('Shipping address', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    order.shippingAddressLabel!,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                  onTap: onOpenProduct == null
                      ? null
                      : () => onOpenProduct!(item.productId),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _OrderSummaryCard(order: order),
      ],
    );

    if (onRefresh == null) return content;

    return RefreshIndicator(onRefresh: onRefresh!, child: content);
  }
}

class _OrderHeaderCard extends StatelessWidget {
  const _OrderHeaderCard({
    required this.order,
    required this.tracking,
    this.onCopyTrackingNumber,
  });

  final Order order;
  final OrderTracking? tracking;
  final ValueChanged<String>? onCopyTrackingNumber;

  @override
  Widget build(BuildContext context) {
    final courierName = tracking?.courierName;
    final trackingNumber = tracking?.trackingNumber;

    return AppCard(
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
                    Text(order.orderNumber, style: AppTextStyles.headlineSmall),
                    if (order.placedAt != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Placed ${_formatDate(order.placedAt!)}',
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
          if (courierName != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _MetaRow(
              icon: Icons.local_shipping_outlined,
              label: 'Courier',
              value: courierName,
            ),
          ],
          if (trackingNumber != null) ...[
            const SizedBox(height: AppSpacing.md),
            _MetaRow(
              icon: Icons.qr_code_2_rounded,
              label: 'Tracking No',
              value: trackingNumber,
              trailing: onCopyTrackingNumber == null
                  ? null
                  : IconButton(
                      tooltip: 'Copy',
                      onPressed: () => onCopyTrackingNumber!(trackingNumber),
                      icon: const Icon(
                        Icons.copy_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ],
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

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(value, style: AppTextStyles.titleSmall),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final subtotal = order.subtotal ?? order.total;
    final shipping = order.shippingFee ?? 0;
    final discount = order.discount ?? 0;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: formatMoney(subtotal)),
          if (shipping > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(label: 'Shipping', value: formatMoney(shipping)),
          ],
          if (discount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(
              label: 'Discount',
              value: '-${formatMoney(discount)}',
              valueColor: AppColors.success,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _SummaryRow(
            label: 'Total',
            value: formatMoney(order.total),
            isEmphasis: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isEmphasis = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isEmphasis;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: isEmphasis
                ? AppTextStyles.titleMedium
                : AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
          ),
        ),
        Text(
          value,
          style: (isEmphasis ? AppTextStyles.price : AppTextStyles.titleSmall)
              .copyWith(color: valueColor),
        ),
      ],
    );
  }
}
