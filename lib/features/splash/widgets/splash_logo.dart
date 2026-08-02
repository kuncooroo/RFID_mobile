import 'package:flutter/material.dart';

import '../../../shared/design_system/app_assets.dart';
import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';

/// Brand mark shown on the splash screen.
class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: AppRadius.xxlAll,
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            AppAssets.logo,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.shopping_bag_rounded,
              size: size * 0.5,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Kutuku',
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Shop smarter',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Compact splash wordmark used when vertical space is tight.
class SplashWordmark extends StatelessWidget {
  const SplashWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Kutuku',
      style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary),
    );
  }
}
