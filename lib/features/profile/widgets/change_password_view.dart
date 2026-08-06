import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_password_field.dart';
import '../../auth/services/auth_validators.dart';

/// Change Password form body (Figma `1:23`).
class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({
    super.key,
    required this.formKey,
    required this.currentController,
    required this.newController,
    required this.confirmController,
    required this.isSubmitting,
    required this.onSubmit,
    this.errorMessage,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController currentController;
  final TextEditingController newController;
  final TextEditingController confirmController;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.xl,
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
              ),
              children: [
                Text(
                  'Choose a strong password you have not used before.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                if (errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.dangerSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                AppPasswordField(
                  controller: currentController,
                  label: 'Current Password',
                  hintText: 'Enter current password',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.password],
                  validator: AuthValidators.password,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPasswordField(
                  controller: newController,
                  label: 'New Password',
                  hintText: 'Enter new password',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) {
                    final base = AuthValidators.password(value);
                    if (base != null) return base;
                    if (value == currentController.text) {
                      return 'New password must be different';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPasswordField(
                  controller: confirmController,
                  label: 'Confirm Password',
                  hintText: 'Re-enter new password',
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: (_) => onSubmit(),
                  validator: (value) => AuthValidators.confirmPassword(
                    value,
                    newController.text,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Use at least 6 characters. Avoid reusing your current password.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.md,
              AppSpacing.screenHorizontal,
              AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: AppButton(
              label: 'Update Password',
              onPressed: isSubmitting ? null : onSubmit,
              isLoading: isSubmitting,
            ),
          ),
        ),
      ],
    );
  }
}
