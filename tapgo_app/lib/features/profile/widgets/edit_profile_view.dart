import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../auth/services/auth_validators.dart';

/// Edit Profile form body (Figma `1:20`).
class EditProfileView extends StatelessWidget {
  const EditProfileView({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.avatarUrl,
    required this.displayName,
    required this.isHydrating,
    required this.isSubmitting,
    required this.onAvatarTap,
    required this.onSubmit,
    required this.onNameChanged,
    this.errorMessage,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final String? avatarUrl;
  final String displayName;
  final bool isHydrating;
  final bool isSubmitting;
  final VoidCallback onAvatarTap;
  final VoidCallback onSubmit;
  final ValueChanged<String> onNameChanged;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (isHydrating) {
      return const AppLoading.page(message: 'Loading profile…');
    }

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
                Center(
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AppAvatar(
                            name: displayName,
                            imageUrl: avatarUrl,
                            size: AppAvatarSize.store,
                            onTap: onAvatarTap,
                          ),
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Material(
                              color: AppColors.primary,
                              shape: const CircleBorder(),
                              elevation: 2,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: onAvatarTap,
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 18,
                                    color: AppColors.textOnPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Change photo',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
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
                AppTextField(
                  controller: nameController,
                  label: 'Full name',
                  hintText: 'Enter your name',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  onChanged: onNameChanged,
                  validator: AuthValidators.name,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: emailController,
                  label: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.mail_outline_rounded),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: _emailValidator,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: phoneController,
                  label: 'Phone number',
                  hintText: 'Enter your phone',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
                  ],
                  onSubmitted: (_) => onSubmit(),
                  validator: _phoneValidator,
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
              label: 'Save Changes',
              onPressed: isSubmitting ? null : onSubmit,
              isLoading: isSubmitting,
            ),
          ),
        ),
      ],
    );
  }

  static String? _emailValidator(String? value) {
    final empty = AuthValidators.required(value, field: 'Email');
    if (empty != null) return empty;
    final trimmed = value!.trim();
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
    if (!ok) return 'Enter a valid email';
    return null;
  }

  static String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return 'Enter a valid phone number';
    return null;
  }
}
