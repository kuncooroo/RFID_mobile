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
              'Your Kutuku account is ready. Start exploring products now.',
          actionLabel: 'Continue Shopping',
          onAction: () => AuthNavigation.goToDashboard(context),
        ),
      ),
    );
  }
}
