import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../state/orders_state.dart';

/// Active / History segment switcher for My Order.
class OrdersSegmentTabs extends StatelessWidget {
  const OrdersSegmentTabs({
    super.key,
    required this.segment,
    required this.onChanged,
  });

  final OrdersSegment segment;
  final ValueChanged<OrdersSegment> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: const BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: AppRadius.pillAll,
        ),
        child: Row(
          children: [
            Expanded(
              child: _SegmentButton(
                label: 'Active',
                selected: segment == OrdersSegment.active,
                onTap: () => onChanged(OrdersSegment.active),
              ),
            ),
            Expanded(
              child: _SegmentButton(
                label: 'History',
                selected: segment == OrdersSegment.history,
                onTap: () => onChanged(OrdersSegment.history),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: AppRadius.pillAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              color: selected
                  ? AppColors.textOnPrimary
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
