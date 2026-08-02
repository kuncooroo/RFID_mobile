import 'package:flutter/material.dart';

import '../design_system/app_assets.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../design_system/text_styles.dart';
import 'app_button.dart';

/// Empty-state placeholder for cart, favorites, search, orders, messages.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.message,
    this.illustrationAsset,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final String? illustrationAsset;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustrationAsset != null)
              Image.asset(
                illustrationAsset!,
                width: 160,
                height: 160,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _FallbackIcon(icon: icon),
              )
            else
              _FallbackIcon(icon: icon),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              title,
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                isExpanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({this.icon});

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon ?? Icons.inbox_outlined,
        size: 40,
        color: AppColors.textTertiary,
      ),
    );
  }
}

/// Preset empty states mapped to Kutuku flows.
abstract final class AppEmptyStates {
  static AppEmptyState cart({VoidCallback? onAction}) => AppEmptyState(
    title: 'Your cart is empty',
    message: 'Find something you love and add it to your cart.',
    illustrationAsset: AppAssets.emptyCart,
    icon: Icons.shopping_bag_outlined,
    actionLabel: onAction == null ? null : 'Start Shopping',
    onAction: onAction,
  );

  static AppEmptyState favorites({VoidCallback? onAction}) => AppEmptyState(
    title: 'No favorites yet',
    message: 'Tap the heart on products to save them here.',
    illustrationAsset: AppAssets.emptyFavorites,
    icon: Icons.favorite_border_rounded,
    actionLabel: onAction == null ? null : 'Explore Products',
    onAction: onAction,
  );

  static AppEmptyState search({VoidCallback? onAction}) => AppEmptyState(
    title: 'No results found',
    message: 'Try a different keyword or adjust your filters.',
    illustrationAsset: AppAssets.emptySearch,
    icon: Icons.search_off_rounded,
    actionLabel: onAction == null ? null : 'Clear Filters',
    onAction: onAction,
  );

  static AppEmptyState orders({VoidCallback? onAction}) => AppEmptyState(
    title: 'No orders yet',
    message: 'Your active and past orders will appear here.',
    illustrationAsset: AppAssets.emptyOrders,
    icon: Icons.local_shipping_outlined,
    actionLabel: onAction == null ? null : 'Shop Now',
    onAction: onAction,
  );
}
