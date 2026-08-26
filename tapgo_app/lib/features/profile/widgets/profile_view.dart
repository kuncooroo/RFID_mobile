import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/sizes.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../navigation/profile_navigation.dart';
import '../state/profile_state.dart';
import 'profile_header.dart';

/// My Profile — single-screen hub with grouped settings (no separate Settings page).
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
      return AppEmptyState(
        title: 'No profile',
        message: 'Sign in to view your profile details.',
        icon: Icons.person_outline_rounded,
        actionLabel: 'Sign In',
        onAction: () => ProfileNavigation.openLogin(context),
      );
    }

    final member = snapshot.member;
    final languageLabel = snapshot.settings.languageLabel;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.lg,
          AppSpacing.screenHorizontal,
          AppSpacing.xxxl,
        ),
        children: [
          ProfileHeader(member: member),
          const SizedBox(height: AppSpacing.xl),
          ProfileStatsRow(
            member: member,
            onOrdersTap: () => ProfileNavigation.openOrders(context),
            onFavoritesTap: () => ProfileNavigation.openFavorites(context),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _ProfileSection(
            title: 'ACCOUNT',
            children: [
              _ProfileMenuTile(
                title: 'Edit Profile',
                icon: Icons.person_outline_rounded,
                onTap: () => ProfileNavigation.openEditProfile(context),
              ),
              _ProfileMenuTile(
                title: 'Change Password',
                icon: Icons.lock_outline_rounded,
                onTap: () => ProfileNavigation.openChangePassword(context),
              ),
              _ProfileMenuTile(
                title: 'Notifications',
                icon: Icons.notifications_none_rounded,
                onTap: () => ProfileNavigation.openNotifications(context),
              ),
              _ProfileMenuTile(
                title: 'Messages',
                icon: Icons.chat_bubble_outline_rounded,
                onTap: () => ProfileNavigation.openMessages(context),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _ProfileSection(
            title: 'PREFERENCES',
            children: [
              _ProfileMenuTile(
                title: 'Language',
                icon: Icons.language_rounded,
                trailingText: languageLabel,
                onTap: () => ProfileNavigation.openLanguage(context),
              ),
              _ProfileMenuTile(
                title: 'Security',
                icon: Icons.shield_outlined,
                onTap: () => ProfileNavigation.openSecurity(context),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _ProfileSection(
            title: 'SUPPORT',
            children: [
              _ProfileMenuTile(
                title: 'Help & Support',
                icon: Icons.help_outline_rounded,
                onTap: () => ProfileNavigation.openHelpSupport(context),
              ),
              _ProfileMenuTile(
                title: 'Legal & Policies',
                icon: Icons.description_outlined,
                onTap: () => ProfileNavigation.openLegalPolicies(context),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _LogoutTile(onTap: onLogout),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: AppRadius.lgAll,
          child: ColoredBox(
            color: AppColors.surfaceMuted,
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.trailingText,
    this.showDivider = true,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final String? trailingText;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: AppSizes.iconMd,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(title, style: AppTextStyles.titleMedium),
                  ),
                  if (trailingText != null) ...[
                    Text(
                      trailingText!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: 52),
            child: Divider(height: 1, thickness: 1, color: AppColors.divider),
          ),
      ],
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.dangerSoft,
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout_rounded,
                size: AppSizes.iconMd,
                color: AppColors.danger,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Logout',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
