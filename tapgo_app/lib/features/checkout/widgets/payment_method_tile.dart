import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../models/payment_method.dart';

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
    this.showRadio = true,
  });

  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showRadio;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      variant: AppCardVariant.outlined,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          if (showRadio)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected ? AppColors.primary : AppColors.borderStrong,
                size: 22,
              ),
            ),
          Container(
            width: 48,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              _brandShort(method.brand),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${method.brand} ${method.maskedNumber}',
                  style: AppTextStyles.titleSmall,
                ),
                if (method.expiryLabel != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Expires ${method.expiryLabel}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (method.isDefault)
            Text(
              'Default',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  String _brandShort(String brand) {
    final value = brand.trim();
    if (value.isEmpty) return 'Card';
    if (value.toLowerCase().startsWith('visa')) return 'VISA';
    if (value.toLowerCase().startsWith('master')) return 'MC';
    if (value.toLowerCase().startsWith('amex')) return 'AMEX';
    return value.length <= 4 ? value.toUpperCase() : value.substring(0, 4).toUpperCase();
  }
}
