import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../models/order.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final OrderStatus status;

  Color get _background => switch (status) {
    OrderStatus.pending => AppColors.warningSoft,
    OrderStatus.paid || OrderStatus.processing => AppColors.infoSoft,
    OrderStatus.shipped => AppColors.primarySoft,
    OrderStatus.delivered => AppColors.successSoft,
    OrderStatus.cancelled || OrderStatus.refunded => AppColors.dangerSoft,
  };

  Color get _foreground => switch (status) {
    OrderStatus.pending => AppColors.warning,
    OrderStatus.paid || OrderStatus.processing => AppColors.info,
    OrderStatus.shipped => AppColors.primary,
    OrderStatus.delivered => AppColors.success,
    OrderStatus.cancelled || OrderStatus.refunded => AppColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        status.label,
        style: AppTextStyles.labelSmall.copyWith(
          color: _foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
