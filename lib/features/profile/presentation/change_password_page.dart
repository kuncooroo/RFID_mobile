import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_password_field.dart';
import '../../auth/services/auth_validators.dart';
import '../providers/profile_providers.dart';
import '../widgets/settings_views.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await ref
        .read(changePasswordControllerProvider.notifier)
        .submit(
          currentPassword: _currentController.text,
          newPassword: _newController.text,
        );
    if (!mounted || !ok) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Password updated')));
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changePasswordControllerProvider);

    return ProfileFormScaffold(
      title: 'Change Password',
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          children: [
            if (state.errorMessage != null) ...[
              ProfileErrorText(message: state.errorMessage!),
              const SizedBox(height: AppSpacing.lg),
            ],
            AppPasswordField(
              controller: _currentController,
              label: 'Current Password',
              hintText: 'Enter current password',
              validator: AuthValidators.password,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppPasswordField(
              controller: _newController,
              label: 'New Password',
              hintText: 'Enter new password',
              autofillHints: const [AutofillHints.newPassword],
              validator: AuthValidators.password,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppPasswordField(
              controller: _confirmController,
              label: 'Confirm Password',
              hintText: 'Re-enter new password',
              autofillHints: const [AutofillHints.newPassword],
              validator: (value) =>
                  AuthValidators.confirmPassword(value, _newController.text),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Update Password',
              onPressed: state.isSubmitting ? null : _submit,
              isLoading: state.isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}
