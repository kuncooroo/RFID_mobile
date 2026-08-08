import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/sizes.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_button.dart';
import '../models/auth_requests.dart';

/// Google / Facebook social sign-in buttons from the Kutuku kit.
class AuthSocialButtons extends StatelessWidget {
  const AuthSocialButtons({
    super.key,
    required this.onGoogle,
    required this.onFacebook,
    this.enabled = true,
  });

  final VoidCallback? onGoogle;
  final VoidCallback? onFacebook;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(
          label: 'Continue with Google',
          variant: AppButtonVariant.social,
          onPressed: enabled ? onGoogle : null,
          leading: const Icon(
            Icons.g_mobiledata_rounded,
            size: AppSizes.iconLg,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Continue with Facebook',
          variant: AppButtonVariant.social,
          onPressed: enabled ? onFacebook : null,
          leading: const Icon(
            Icons.facebook_rounded,
            size: AppSizes.iconMd,
            color: Color(0xFF1877F2),
          ),
        ),
      ],
    );
  }
}

extension AuthSocialProviderX on AuthSocialProvider {
  String get label => switch (this) {
    AuthSocialProvider.google => 'Google',
    AuthSocialProvider.facebook => 'Facebook',
  };
}
