import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../settings/models/settings.dart';

/// Security preferences body (Figma Security settings).
class SecurityView extends StatelessWidget {
  const SecurityView({
    super.key,
    required this.settings,
    required this.onBiometricChanged,
    required this.onTwoFactorChanged,
    required this.onChangePassword,
    this.isLoading = false,
    this.hasLoadFailed = false,
    this.isSaving = false,
    this.errorMessage,
    this.onRetry,
  });

  final Settings settings;
  final ValueChanged<bool> onBiometricChanged;
  final ValueChanged<bool> onTwoFactorChanged;
  final VoidCallback onChangePassword;
  final bool isLoading;
  final bool hasLoadFailed;
  final bool isSaving;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const AppLoading.page(message: 'Loading security…');
    }

    if (hasLoadFailed) {
      return AppErrorState(
        title: 'Could not load security',
        message: errorMessage ?? 'Please try again.',
        onRetry: onRetry,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.xl,
        AppSpacing.screenHorizontal,
        AppSpacing.xxxl,
      ),
      children: [
        Text(
          'Protect your Kutuku account with biometrics, two-factor authentication, and a strong password.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('SIGN-IN PROTECTION', style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.md),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.settingsTile,
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              _SecurityToggleTile(
                icon: Icons.fingerprint_rounded,
                title: 'Biometric login',
                subtitle: 'Use Face ID or fingerprint to sign in faster',
                value: settings.biometricEnabled,
                enabled: !isSaving,
                onChanged: onBiometricChanged,
              ),
              const Divider(
                height: 1,
                thickness: 1,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
                color: AppColors.divider,
              ),
              _SecurityToggleTile(
                icon: Icons.phonelink_lock_rounded,
                title: 'Two-factor authentication',
                subtitle: 'Require a one-time code when signing in',
                value: settings.twoFactorEnabled,
                enabled: !isSaving,
                onChanged: onTwoFactorChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('PASSWORD', style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.md),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.settingsTile,
            border: Border.all(color: AppColors.divider),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account password',
                            style: AppTextStyles.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Update your password regularly to keep your account safe.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Change Password',
                  variant: AppButtonVariant.outline,
                  onPressed: isSaving ? null : onChangePassword,
                ),
              ],
            ),
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            errorMessage!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}

class _SecurityToggleTile extends StatelessWidget {
  const _SecurityToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: value ? AppColors.primarySoft : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: value
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : AppColors.divider,
              ),
            ),
            child: Icon(
              icon,
              color: value ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }
}
