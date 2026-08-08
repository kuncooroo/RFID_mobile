import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_password_field.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../navigation/auth_navigation.dart';
import '../providers/auth_providers.dart';
import '../services/auth_validators.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_scaffold.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, this.initialIdentifier, this.token});

  final String? initialIdentifier;
  final String? token;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _identifierController;
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController(
      text: widget.initialIdentifier ?? '',
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await ref
        .read(resetPasswordControllerProvider.notifier)
        .submit(
          identifier: _identifierController.text,
          password: _passwordController.text,
          passwordConfirmation: _confirmController.text,
          token: widget.token,
        );
    if (!mounted || !ok) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated. Please login.')),
    );
    AuthNavigation.goToLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetPasswordControllerProvider);
    final busy = state.isSubmitting;

    return AuthScaffold(
      onBack: () => AuthNavigation.popOrLogin(context),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(
              title: 'New Password',
              subtitle: 'Create a new password for your Kutuku account.',
            ),
            const SizedBox(height: AppSpacing.xxxl),
            if (state.errorMessage != null) ...[
              AuthErrorBanner(message: state.errorMessage!),
              const SizedBox(height: AppSpacing.lg),
            ],
            AppTextField(
              controller: _identifierController,
              label: 'Email / Phone',
              hintText: 'Enter your email or phone',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.mail_outline_rounded),
              validator: AuthValidators.identifier,
              enabled: !busy,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppPasswordField(
              controller: _passwordController,
              label: 'New Password',
              hintText: 'Enter new password',
              textInputAction: TextInputAction.next,
              validator: AuthValidators.password,
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppPasswordField(
              controller: _confirmController,
              label: 'Confirm Password',
              hintText: 'Re-enter new password',
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (value) => AuthValidators.confirmPassword(
                value,
                _passwordController.text,
              ),
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Save Password',
              onPressed: busy ? null : _submit,
              isLoading: busy,
            ),
          ],
        ),
      ),
    );
  }
}
