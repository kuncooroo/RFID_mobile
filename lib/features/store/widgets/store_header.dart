import 'package:flutter/material.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_button.dart';
import '../models/store.dart';

/// Store profile header with avatar, stats, and optional follow CTA.
class StoreHeader extends StatelessWidget {
  const StoreHeader({
    super.key,
    required this.store,
    required this.isFollowing,
    required this.onFollowTap,
  });

  final Store store;
  final bool isFollowing;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          AppAvatar(
            imageUrl: store.logoUrl,
            name: store.name,
            size: AppAvatarSize.store,
            showVerifiedBadge: store.isVerified,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(store.name, style: AppTextStyles.headlineSmall),
          if (store.location != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(store.location!, style: AppTextStyles.bodySmall),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatItem(
                label: 'Products',
                value: '${store.productCount}',
              ),
              const SizedBox(width: AppSpacing.xxxl),
              _StatItem(
                label: 'Followers',
                value: _formatCount(store.followersCount),
              ),
              if (store.rating > 0) ...[
                const SizedBox(width: AppSpacing.xxxl),
                _StatItem(
                  label: 'Rating',
                  value: store.rating.toStringAsFixed(1),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: isFollowing ? 'Following' : 'Follow',
            variant: isFollowing
                ? AppButtonVariant.secondary
                : AppButtonVariant.primary,
            onPressed: onFollowTap,
            isExpanded: false,
            height: 40,
          ),
          if (store.description != null && store.description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              store.description!,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.section),
        ],
      ),
    );
  }

  String _formatCount(int count) {
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
