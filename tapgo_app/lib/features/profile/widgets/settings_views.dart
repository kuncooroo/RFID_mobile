import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_settings_tile.dart';
import '../../settings/models/settings.dart';
import '../navigation/profile_navigation.dart';
import '../state/profile_state.dart';
import 'language_view.dart';
import 'security_view.dart';

class SettingsHubView extends StatelessWidget {
  const SettingsHubView({
    super.key,
    required this.state,
    this.onLogout,
  });

  final SettingsUiState state;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      children: [
        Text('Account', style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.md),
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
        const SizedBox(height: AppSpacing.xxl),
        Text('Preferences', style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.md),
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
        const SizedBox(height: AppSpacing.xxl),
        Text('Support', style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.md),
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
        if (onLogout != null) ...[
          const SizedBox(height: AppSpacing.xxl),
          AppSettingsTile(
            title: 'Logout',
            leading: const Icon(Icons.logout_rounded),
            isDestructive: true,
            showChevron: false,
            onTap: onLogout,
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
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
        Text(
          'Choose which alerts you want to receive.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _PreferenceSwitch(
          title: 'Push notifications',
          subtitle: 'Alerts on this device',
          value: settings.pushNotificationsEnabled,
          onChanged: (value) =>
              onChanged(settings.copyWith(pushNotificationsEnabled: value)),
        ),
        _PreferenceSwitch(
          title: 'Email notifications',
          subtitle: 'Updates sent to your inbox',
          value: settings.emailNotificationsEnabled,
          onChanged: (value) =>
              onChanged(settings.copyWith(emailNotificationsEnabled: value)),
        ),
        _PreferenceSwitch(
          title: 'Order updates',
          subtitle: 'Shipping and delivery status',
          value: settings.orderUpdatesEnabled,
          onChanged: (value) =>
              onChanged(settings.copyWith(orderUpdatesEnabled: value)),
        ),
        _PreferenceSwitch(
          title: 'Promotions',
          subtitle: 'Deals, vouchers, and offers',
          value: settings.promoNotificationsEnabled,
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
    return SecurityView(
      settings: settings,
      onBiometricChanged: (value) =>
          onChanged(settings.copyWith(biometricEnabled: value)),
      onTwoFactorChanged: (value) =>
          onChanged(settings.copyWith(twoFactorEnabled: value)),
      onChangePassword: () => ProfileNavigation.openChangePassword(context),
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
    return LanguageView(
      languages: state.languages,
      selectedCode: state.settings.languageCode,
      isLoading: state.isLoading,
      errorMessage: state.errorMessage,
      onSelect: onSelect,
    );
  }
}

class _PreferenceSwitch extends StatelessWidget {
  const _PreferenceSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTextStyles.titleMedium),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      value: value,
      activeThumbColor: AppColors.primary,
      activeTrackColor: AppColors.primaryLight,
      onChanged: onChanged,
    );
  }
}

/// Shared form chrome for edit profile / change password / settings pages.
class ProfileFormScaffold extends StatelessWidget {
  const ProfileFormScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

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
        title: Text(title, style: AppTextStyles.headlineSmall),
        centerTitle: false,
        actions: actions,
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
