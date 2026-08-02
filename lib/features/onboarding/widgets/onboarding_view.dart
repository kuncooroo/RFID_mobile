import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_loading.dart';
import '../state/onboarding_state.dart';
import 'onboarding_actions.dart';
import 'onboarding_page_indicator.dart';
import 'onboarding_slide.dart';

/// Full onboarding layout: PageView + dots + auth CTAs.
class OnboardingView extends StatelessWidget {
  const OnboardingView({
    super.key,
    required this.state,
    required this.pageController,
    required this.onPageChanged,
    required this.onCreateAccount,
    required this.onSignIn,
    this.onRetry,
  });

  final OnboardingState state;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? onCreateAccount;
  final VoidCallback? onSignIn;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (state.isLoading) {
      return const AppLoading.page(message: 'Loading…');
    }

    if (state.hasFailed && state.pages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Could not load onboarding',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.errorMessage ?? 'Please try again.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Try Again',
              onPressed: onRetry,
              isExpanded: false,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: pageController,
            itemCount: state.pageCount,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              return OnboardingSlide(data: state.pages[index]);
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        OnboardingPageIndicator(
          count: state.pageCount,
          index: state.currentIndex,
        ),
        const SizedBox(height: AppSpacing.xxxl),
        OnboardingActions(
          onCreateAccount: onCreateAccount,
          onSignIn: onSignIn,
          isBusy: state.isCompleting,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
