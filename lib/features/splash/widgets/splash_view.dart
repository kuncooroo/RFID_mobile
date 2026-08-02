import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_loading.dart';
import '../state/splash_state.dart';
import 'splash_logo.dart';

/// Full-bleed splash content: branding + loading / error actions.
class SplashView extends StatelessWidget {
  const SplashView({super.key, required this.state, this.onRetry});

  final SplashState state;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
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
              _Footer(state: state, onRetry: onRetry),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state, this.onRetry});

  final SplashState state;
  final VoidCallback? onRetry;

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
          AppButton(label: 'Try Again', onPressed: onRetry, isExpanded: false),
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
