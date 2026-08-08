import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/utils/money.dart';
import '../../../shared/widgets/app_button.dart';

/// Sticky checkout CTA bar for My Cart.
class CartCheckoutBar extends StatelessWidget {
  const CartCheckoutBar({
    super.key,
    required this.total,
    required this.onCheckout,
    this.selectedCount = 0,
    this.enabled = true,
  });

  final double total;
  final int selectedCount;
  final bool enabled;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total ($selectedCount)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(formatMoney(total), style: AppTextStyles.priceLarge),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            AppButton(
              label: 'Checkout',
              onPressed: enabled ? onCheckout : null,
              isExpanded: false,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }
}
