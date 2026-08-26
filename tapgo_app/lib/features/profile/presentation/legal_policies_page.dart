import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/text_styles.dart';
import '../navigation/profile_navigation.dart';
import '../widgets/legal_policies_view.dart';

/// Legal & Policies screen.
class LegalPoliciesPage extends StatelessWidget {
  const LegalPoliciesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => ProfileNavigation.pop(context),
        ),
        title: Text('Legal & Policies', style: AppTextStyles.headlineSmall),
        centerTitle: false,
      ),
      body: LegalPoliciesView(
        onContactSupport: () => ProfileNavigation.openHelpSupport(context),
      ),
    );
  }
}
