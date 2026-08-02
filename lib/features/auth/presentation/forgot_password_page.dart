import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../navigation/auth_navigation.dart';
import '../providers/auth_providers.dart';
import '../services/auth_validators.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_scaffold.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key, this.initialIdentifier});

  final String? initialIdentifier;

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _identifierController;

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
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await ref
        .read(forgotPasswordControllerProvider.notifier)
        .submit(identifier: _identifierController.text);
    if (!mounted || !ok) return;

    AuthNavigation.goToResetPassword(
      context,
      identifier: _identifierController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);
    final busy = state.isSubmitting;

    return AuthScaffold(
      onBack: () => AuthNavigation.popOrLogin(context),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(
              title: 'Forgot Password',
              subtitle:
                  'Enter your email or phone and we will help you reset your password.',
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
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              autofillHints: const [
                AutofillHints.email,
                AutofillHints.telephoneNumber,
              ],
              prefixIcon: const Icon(Icons.mail_outline_rounded),
              validator: AuthValidators.identifier,
              enabled: !busy,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Continue',
              onPressed: busy ? null : _submit,
              isLoading: busy,
            ),
          ],
        ),
      ),
    );
  }
}
