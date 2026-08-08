import 'package:flutter/material.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_button.dart';

/// Bottom CTAs matching Kutuku onboarding: Create Account + sign-in link.
class OnboardingActions extends StatelessWidget {
  const OnboardingActions({
    super.key,
    required this.onCreateAccount,
    required this.onSignIn,
    this.isBusy = false,
  });

  final VoidCallback? onCreateAccount;
  final VoidCallback? onSignIn;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            label: 'Create Account',
            onPressed: isBusy ? null : onCreateAccount,
            isLoading: isBusy,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Already Have an Account',
            variant: AppButtonVariant.text,
            onPressed: isBusy ? null : onSignIn,
          ),
        ],
      ),
    );
  }
}
