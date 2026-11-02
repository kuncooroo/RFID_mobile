import 'package:flutter/material.dart';

import '../design_system/app_assets.dart';
import '../l10n/app_text.dart';
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
            _EmptyVisual(icon: icon),
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

class _EmptyVisual extends StatelessWidget {
  const _EmptyVisual({this.icon});

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return _IconBadge(icon: icon);
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({this.icon});

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      height: 148,
      decoration: const BoxDecoration(
        color: AppColors.primarySoft,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 92,
        height: 92,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon ?? Icons.inbox_outlined,
          size: 46,
          color: AppColors.white,
        ),
      ),
    );
  }
}

/// Preset empty states mapped to WanderDesa flows.
abstract final class AppEmptyStates {
  static AppEmptyState cart(BuildContext context, {VoidCallback? onAction}) {
    final copy = AppText.of(context);
    return AppEmptyState(
      title: copy.emptyCartTitle,
      message: copy.emptyCartBody,
      illustrationAsset: AppAssets.emptyCart,
      icon: Icons.shopping_bag_outlined,
      actionLabel: onAction == null ? null : copy.startShopping,
      onAction: onAction,
    );
  }

  static AppEmptyState favorites(BuildContext context, {VoidCallback? onAction}) {
    final copy = AppText.of(context);
    return AppEmptyState(
      title: copy.emptyFavoritesTitle,
      message: copy.emptyFavoritesBody,
      illustrationAsset: AppAssets.emptyFavorites,
      icon: Icons.favorite_border_rounded,
      actionLabel: onAction == null ? null : copy.exploreProducts,
      onAction: onAction,
    );
  }

  static AppEmptyState search(BuildContext context, {VoidCallback? onAction}) {
    final copy = AppText.of(context);
    return AppEmptyState(
      title: copy.emptySearchTitle,
      message: copy.emptySearchBody,
      illustrationAsset: AppAssets.emptySearch,
      icon: Icons.search_off_rounded,
      actionLabel: onAction == null ? null : copy.t('Clear Filters', 'Hapus filter'),
      onAction: onAction,
    );
  }

  static AppEmptyState orders(BuildContext context, {VoidCallback? onAction}) {
    final copy = AppText.of(context);
    return AppEmptyState(
      title: copy.emptyOrdersTitle,
      message: copy.emptyOrdersBody,
      illustrationAsset: AppAssets.emptyOrders,
      icon: Icons.local_shipping_outlined,
      actionLabel: onAction == null ? null : copy.shopNow,
      onAction: onAction,
    );
  }
}
