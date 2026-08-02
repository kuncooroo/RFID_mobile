import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_settings_tile.dart';
import '../../settings/models/settings.dart';
import '../navigation/profile_navigation.dart';
import '../state/profile_state.dart';

class SettingsHubView extends StatelessWidget {
  const SettingsHubView({super.key, required this.state});

  final SettingsUiState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      children: [
        AppSettingsTile(
          title: 'Edit Profile',
          leading: const Icon(Icons.person_outline_rounded),
          onTap: () => ProfileNavigation.openEditProfile(context),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSettingsTile(
          title: 'Change Password',
          leading: const Icon(Icons.lock_outline_rounded),
          onTap: () => ProfileNavigation.openChangePassword(context),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSettingsTile(
          title: 'Notifications',
          leading: const Icon(Icons.notifications_none_rounded),
          onTap: () => ProfileNavigation.openNotificationSettings(context),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSettingsTile(
          title: 'Security',
          leading: const Icon(Icons.security_rounded),
          onTap: () => ProfileNavigation.openSecurity(context),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSettingsTile(
          title: 'Language',
          leading: const Icon(Icons.language_rounded),
          trailingText: state.settings.languageLabel,
          onTap: () => ProfileNavigation.openLanguage(context),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSettingsTile(
          title: 'Help & Support',
          leading: const Icon(Icons.help_outline_rounded),
          onTap: () => ProfileNavigation.openHelpSupport(context),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSettingsTile(
          title: 'Legal & Policies',
          leading: const Icon(Icons.description_outlined),
          onTap: () => ProfileNavigation.openLegalPolicies(context),
        ),
      ],
    );
  }
}

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final Settings settings;
  final ValueChanged<Settings> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      children: [
        SwitchListTile(
          title: const Text('Push notifications'),
          value: settings.pushNotificationsEnabled,
          activeThumbColor: AppColors.primary,
          onChanged: (value) =>
              onChanged(settings.copyWith(pushNotificationsEnabled: value)),
        ),
        SwitchListTile(
          title: const Text('Email notifications'),
          value: settings.emailNotificationsEnabled,
          activeThumbColor: AppColors.primary,
          onChanged: (value) =>
              onChanged(settings.copyWith(emailNotificationsEnabled: value)),
        ),
        SwitchListTile(
          title: const Text('Order updates'),
          value: settings.orderUpdatesEnabled,
          activeThumbColor: AppColors.primary,
          onChanged: (value) =>
              onChanged(settings.copyWith(orderUpdatesEnabled: value)),
        ),
        SwitchListTile(
          title: const Text('Promotions'),
          value: settings.promoNotificationsEnabled,
          activeThumbColor: AppColors.primary,
          onChanged: (value) =>
              onChanged(settings.copyWith(promoNotificationsEnabled: value)),
        ),
      ],
    );
  }
}

class SecuritySettingsView extends StatelessWidget {
  const SecuritySettingsView({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final Settings settings;
  final ValueChanged<Settings> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      children: [
        SwitchListTile(
          title: const Text('Biometric login'),
          subtitle: const Text('Use Face ID / fingerprint'),
          value: settings.biometricEnabled,
          activeThumbColor: AppColors.primary,
          onChanged: (value) =>
              onChanged(settings.copyWith(biometricEnabled: value)),
        ),
        SwitchListTile(
          title: const Text('Two-factor authentication'),
          subtitle: const Text('Extra security for sign-in'),
          value: settings.twoFactorEnabled,
          activeThumbColor: AppColors.primary,
          onChanged: (value) =>
              onChanged(settings.copyWith(twoFactorEnabled: value)),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Change Password',
          variant: AppButtonVariant.outline,
          onPressed: () => ProfileNavigation.openChangePassword(context),
        ),
      ],
    );
  }
}

class LanguageSettingsView extends StatelessWidget {
  const LanguageSettingsView({
    super.key,
    required this.state,
    required this.onSelect,
  });

  final SettingsUiState state;
  final ValueChanged<LanguageOption> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      itemCount: state.languages.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final option = state.languages[index];
        final selected = option.code == state.settings.languageCode;
        return AppSettingsTile(
          title: option.label,
          trailingText: selected ? 'Selected' : null,
          showChevron: !selected,
          onTap: () => onSelect(option),
          leading: Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: selected ? AppColors.primary : AppColors.textTertiary,
          ),
        );
      },
    );
  }
}

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      children: [
        Text('Need help?', style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Contact Kutuku support or browse common questions below.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const AppSettingsTile(
          title: 'Order issues',
          leading: Icon(Icons.local_shipping_outlined),
          showChevron: false,
        ),
        const SizedBox(height: AppSpacing.sm),
        const AppSettingsTile(
          title: 'Payments & refunds',
          leading: Icon(Icons.payments_outlined),
          showChevron: false,
        ),
        const SizedBox(height: AppSpacing.sm),
        const AppSettingsTile(
          title: 'Account access',
          leading: Icon(Icons.manage_accounts_outlined),
          showChevron: false,
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'support@kutuku.app',
          style: AppTextStyles.link,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class LegalPoliciesView extends StatelessWidget {
  const LegalPoliciesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      children: const [
        AppSettingsTile(
          title: 'Terms of Service',
          leading: Icon(Icons.article_outlined),
          showChevron: false,
        ),
        SizedBox(height: AppSpacing.sm),
        AppSettingsTile(
          title: 'Privacy Policy',
          leading: Icon(Icons.privacy_tip_outlined),
          showChevron: false,
        ),
        SizedBox(height: AppSpacing.sm),
        AppSettingsTile(
          title: 'Return Policy',
          leading: Icon(Icons.assignment_return_outlined),
          showChevron: false,
        ),
      ],
    );
  }
}

/// Shared form chrome for edit profile / change password.
class ProfileFormScaffold extends StatelessWidget {
  const ProfileFormScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(title, style: AppTextStyles.headlineSmall),
      ),
      body: child,
    );
  }
}

class ProfileErrorText extends StatelessWidget {
  const ProfileErrorText({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
    );
  }
}
