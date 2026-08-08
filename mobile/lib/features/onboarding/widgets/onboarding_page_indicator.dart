import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/sizes.dart';
import '../../../shared/design_system/spacing.dart';

/// Expanding-dot page indicator for the onboarding carousel.
class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    super.key,
    required this.count,
    required this.index,
  });

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();

    return AnimatedSmoothIndicator(
      activeIndex: index.clamp(0, count - 1),
      count: count,
      effect: ExpandingDotsEffect(
        dotHeight: AppSizes.pageDot,
        dotWidth: AppSizes.pageDot,
        expansionFactor: AppSizes.pageDotActiveWidth / AppSizes.pageDot,
        spacing: AppSpacing.sm,
        activeDotColor: AppColors.primary,
        dotColor: AppColors.borderStrong,
      ),
    );
  }
}
