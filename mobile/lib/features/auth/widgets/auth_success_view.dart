import 'package:flutter/material.dart';

import '../../../shared/design_system/app_assets.dart';
import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_image.dart';

/// Register success content (illustration + CTA).
class AuthSuccessView extends StatelessWidget {
  const AuthSuccessView({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.illustrationAsset = AppAssets.successRegister,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final String illustrationAsset;

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
              assetPath: illustrationAsset,
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
                  Icons.check_rounded,
                  size: 72,
                  color: AppColors.success,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            title,
            style: AppTextStyles.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 3),
          AppButton(label: actionLabel, onPressed: onAction),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
