import 'package:flutter/material.dart';

import '../navigation/auth_navigation.dart';
import '../widgets/auth_success_view.dart';

class RegisterSuccessPage extends StatelessWidget {
  const RegisterSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AuthSuccessView(
          title: 'Account Created!',
          message:
              'Your Kutuku account is ready. Sign in to start exploring products.',
          actionLabel: 'Go to Login',
          onAction: () => AuthNavigation.goToLogin(context),
        ),
      ),
    );
  }
}
