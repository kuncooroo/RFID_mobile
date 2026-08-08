import 'package:flutter/material.dart';

import '../../../shared/design_system/app_assets.dart';
import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_image.dart';

class CheckoutSuccessView extends StatelessWidget {
  const CheckoutSuccessView({
    super.key,
    this.orderId,
    required this.onViewOrder,
    required this.onBackToHome,
  });

  final String? orderId;
  final VoidCallback onViewOrder;
  final VoidCallback onBackToHome;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        children: [
          const Spacer(flex: 2),
          SizedBox(
            width: 180,
            height: 180,
            child: AppImage(
              assetPath: AppAssets.successPayment,
              width: 180,
              height: 180,
              fit: BoxFit.contain,
              borderRadius: AppRadius.xxxlAll,
              errorWidget: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  color: AppColors.successSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 72,
                  color: AppColors.success,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            'Payment Successful!',
            style: AppTextStyles.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            orderId == null
                ? 'Your order has been placed successfully. Thank you for shopping with Kutuku!'
                : 'Your order $orderId has been placed successfully. Thank you for shopping with Kutuku!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 3),
          AppButton(label: 'View Order', onPressed: onViewOrder),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Back to Home',
            variant: AppButtonVariant.secondary,
            onPressed: onBackToHome,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
