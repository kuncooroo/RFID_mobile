import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_password_field.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../models/auth_requests.dart';
import '../navigation/auth_navigation.dart';
import '../providers/auth_providers.dart';
import '../services/auth_validators.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_social_buttons.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await ref
        .read(loginControllerProvider.notifier)
        .submit(
          identifier: _identifierController.text,
          password: _passwordController.text,
        );
    // GoRouter redirect handles dashboard when session becomes authenticated.
    if (!mounted || !ok) return;
  }

  Future<void> _social(AuthSocialProvider provider) async {
    FocusScope.of(context).unfocus();
    await ref.read(loginControllerProvider.notifier).submitSocial(provider);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final busy = state.isSubmitting;

    return AuthScaffold(
      showBack: false,
      footer: AuthFooterLink(
        prompt: "Don't have an account?",
        actionLabel: 'Register',
        onAction: () => AuthNavigation.goToRegister(context),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(
              title: 'Login',
              subtitle: 'Welcome back! Please enter your details.',
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
              autofillHints: const [
                AutofillHints.username,
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
            ),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                label: 'Forgot Password?',
                variant: AppButtonVariant.text,
                onPressed: busy
                    ? null
                    : () => AuthNavigation.goToForgotPassword(
                        context,
                        identifier: _identifierController.text,
                      ),
                isExpanded: false,
                height: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Login',
              onPressed: busy ? null : _submit,
              isLoading: busy,
            ),
            const SizedBox(height: AppSpacing.xxl),
            const AuthDivider(),
            const SizedBox(height: AppSpacing.xxl),
            AuthSocialButtons(
              enabled: !busy,
              onGoogle: () => _social(AuthSocialProvider.google),
              onFacebook: () => _social(AuthSocialProvider.facebook),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
