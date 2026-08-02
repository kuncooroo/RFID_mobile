import 'package:flutter/material.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_settings_tile.dart';
import '../navigation/profile_navigation.dart';
import '../state/profile_state.dart';
import 'profile_header.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onRefresh,
    required this.onLogout,
  });

  final ProfileState state;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.snapshot == null) {
      return const AppLoading.page(message: 'Loading profile…');
    }

    if (state.hasFailed && state.snapshot == null) {
      return AppErrorState(
        title: 'Could not load profile',
        message: state.errorMessage ?? 'Please try again.',
        onRetry: onRetry,
      );
    }

    final snapshot = state.snapshot;
    if (snapshot == null) {
      return const AppEmptyState(
        title: 'No profile',
        message: 'Sign in to view your profile details.',
        icon: Icons.person_outline_rounded,
      );
    }

    final member = snapshot.member;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.lg,
        ),
        children: [
          ProfileHeader(
            member: member,
            onEdit: () => ProfileNavigation.openEditProfile(context),
          ),
          const SizedBox(height: AppSpacing.xl),
          ProfileStatsRow(
            member: member,
            onOrdersTap: () => ProfileNavigation.openOrders(context),
            onFavoritesTap: () => ProfileNavigation.openFavorites(context),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppSettingsTile(
            title: 'Notifications',
            leading: const Icon(Icons.notifications_none_rounded),
            onTap: () => ProfileNavigation.openNotifications(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppSettingsTile(
            title: 'Messages',
            leading: const Icon(Icons.chat_bubble_outline_rounded),
            onTap: () => ProfileNavigation.openMessages(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppSettingsTile(
            title: 'Settings',
            leading: const Icon(Icons.settings_outlined),
            trailingText: snapshot.settings.languageLabel,
            onTap: () => ProfileNavigation.openSettings(context),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: 'Logout',
            variant: AppButtonVariant.destructive,
            onPressed: onLogout,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
