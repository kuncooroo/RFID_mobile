import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_image.dart';
import '../models/onboarding_page_data.dart';

/// One onboarding slide: illustration + title + description.
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({super.key, required this.data});

  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final imageSize = (size.width - (AppSpacing.screenHorizontal * 2)).clamp(
      240.0,
      335.0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: imageSize,
            height: imageSize,
            child: AppImage(
              assetPath: data.illustrationAsset,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              borderRadius: AppRadius.xxxlAll,
              errorWidget: _IllustrationFallback(size: imageSize),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            data.title,
            style: AppTextStyles.headlineLarge.copyWith(height: 1.25),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            data.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _IllustrationFallback extends StatelessWidget {
  const _IllustrationFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppRadius.xxxlAll,
      ),
      child: const Icon(
        Icons.shopping_bag_outlined,
        size: 64,
        color: AppColors.primary,
      ),
    );
  }
}
