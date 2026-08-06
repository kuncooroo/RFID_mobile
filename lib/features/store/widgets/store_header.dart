import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/design_system/sizes.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_image.dart';
import '../models/store.dart';

/// Kutuku Store Detail profile header (banner, avatar, stats, follow).
class StoreHeader extends StatelessWidget {
  const StoreHeader({
    super.key,
    required this.store,
    required this.isFollowing,
    required this.onFollowTap,
    this.onMessageTap,
  });

  final Store store;
  final bool isFollowing;
  final VoidCallback onFollowTap;
  final VoidCallback? onMessageTap;

  static const double bannerHeight = 140;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: bannerHeight + AppSizes.avatarXl / 2,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: bannerHeight,
                child: _Banner(store: store),
              ),
              Positioned(
                bottom: 0,
                child: AppAvatar(
                  imageUrl: store.logoUrl,
                  name: store.name,
                  size: AppAvatarSize.xl,
                  showVerifiedBadge: store.isVerified,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.md,
            AppSpacing.screenHorizontal,
            0,
          ),
          child: Column(
            children: [
              Text(
                store.name,
                style: AppTextStyles.headlineSmall,
                textAlign: TextAlign.center,
              ),
              if (store.location != null && store.location!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: AppSizes.iconXs,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Flexible(
                      child: Text(
                        store.location!,
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              _ActionRow(
                isFollowing: isFollowing,
                onFollowTap: onFollowTap,
                onMessageTap: onMessageTap,
              ),
              const SizedBox(height: AppSpacing.xl),
              _StatsRow(store: store),
              if (store.description != null &&
                  store.description!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                Text(
                  store.description!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.section),
            ],
          ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final hasBanner = store.bannerUrl != null && store.bannerUrl!.isNotEmpty;

    return hasBanner
        ? AppImage(
            imageUrl: store.bannerUrl,
            width: double.infinity,
            height: StoreHeader.bannerHeight,
            borderRadius: BorderRadius.zero,
            fit: BoxFit.cover,
          )
        : const ColoredBox(color: AppColors.primarySoft);
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.isFollowing,
    required this.onFollowTap,
    this.onMessageTap,
  });

  final bool isFollowing;
  final VoidCallback onFollowTap;
  final VoidCallback? onMessageTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: isFollowing ? 'Following' : 'Follow',
            variant: isFollowing
                ? AppButtonVariant.secondary
                : AppButtonVariant.primary,
            size: AppButtonSize.small,
            onPressed: onFollowTap,
          ),
        ),
        if (onMessageTap != null) ...[
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppButton(
              label: 'Message',
              variant: AppButtonVariant.outline,
              size: AppButtonSize.small,
              leading: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              onPressed: onMessageTap,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadius.lgAll,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: 'Products',
              value: '${store.productCount}',
            ),
          ),
          Container(width: 1, height: 28, color: AppColors.border),
          Expanded(
            child: _StatItem(
              label: 'Followers',
              value: _formatCount(store.followersCount),
            ),
          ),
          if (store.rating > 0) ...[
            Container(width: 1, height: 28, color: AppColors.border),
            Expanded(
              child: _StatItem(
                label: 'Rating',
                value: store.rating.toStringAsFixed(1),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return '$count';
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.xxs),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
