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
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_scaffold.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await ref
        .read(registerControllerProvider.notifier)
        .submit(
          name: _nameController.text,
          identifier: _identifierController.text,
          password: _passwordController.text,
        );
    if (!mounted || !ok) return;
    // Session is authenticated; GoRouter redirects auth routes → Home.
    // Keep success screen as a soft landing when redirect is delayed.
    AuthNavigation.goToRegisterSuccess(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);
    final busy = state.isSubmitting;

    return AuthScaffold(
      onBack: () => AuthNavigation.goToLogin(context),
      footer: AuthFooterLink(
        prompt: 'Already have an account?',
        actionLabel: 'Login',
        onAction: () => AuthNavigation.goToLogin(context),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(
              title: 'Create Account',
              subtitle: 'Start shopping smarter with Kutuku.',
            ),
            const SizedBox(height: AppSpacing.xxxl),
            if (state.errorMessage != null) ...[
              AuthErrorBanner(message: state.errorMessage!),
              const SizedBox(height: AppSpacing.lg),
            ],
            AppTextField(
              controller: _nameController,
              label: 'Name',
              hintText: 'Enter your name',
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              prefixIcon: const Icon(Icons.person_outline_rounded),
              validator: AuthValidators.name,
              enabled: !busy,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _identifierController,
              label: 'Email / Phone',
              hintText: 'Enter your email or phone',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [
                AutofillHints.email,
                AutofillHints.telephoneNumber,
              ],
              prefixIcon: const Icon(Icons.mail_outline_rounded),
              validator: AuthValidators.identifier,
              enabled: !busy,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppPasswordField(
              controller: _passwordController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: AuthValidators.password,
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Create Account',
              onPressed: busy ? null : _submit,
              isLoading: busy,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
