import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_loading.dart';
import '../models/splash_statistic.dart';
import '../state/splash_state.dart';
import 'splash_logo.dart';
import 'statistics_intro_view.dart';

/// Full-bleed splash content: loader, Statistics intro, or error.
class SplashView extends StatelessWidget {
  const SplashView({
    super.key,
    required this.state,
    required this.statistics,
    this.onRetry,
    this.onGetStarted,
  });

  final SplashState state;
  final List<SplashStatistic> statistics;
  final VoidCallback? onRetry;
  final VoidCallback? onGetStarted;

  @override
  Widget build(BuildContext context) {
    if (state.showIntro) {
      return StatisticsIntroView(
        statistics: statistics,
        onGetStarted: onGetStarted,
      );
    }

    return ColoredBox(
      color: AppColors.background,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primarySoft,
              AppColors.background,
              AppColors.background,
            ],
            stops: [0, 0.45, 1],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.xxl,
            ),
            child: Column(
              children: [
                const Spacer(flex: 3),
                const SplashLogo(),
                const Spacer(flex: 2),
                _Footer(
                  state: state,
                  onRetry: onRetry,
                  onContinueAnyway: onGetStarted,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.state,
    this.onRetry,
    this.onContinueAnyway,
  });

  final SplashState state;
  final VoidCallback? onRetry;
  final VoidCallback? onContinueAnyway;

  @override
  Widget build(BuildContext context) {
    if (state.hasFailed) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Could not start the app',
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
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Try Again',
            onPressed: onRetry,
            isExpanded: false,
          ),
          if (onContinueAnyway != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Continue anyway',
              variant: AppButtonVariant.text,
              onPressed: onContinueAnyway,
              isExpanded: false,
            ),
          ],
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppLoading(size: 28),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Preparing your experience…',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
