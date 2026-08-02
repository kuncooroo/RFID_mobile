import 'package:flutter/material.dart';

import '../../../shared/design_system/app_assets.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../models/favorite.dart';
import '../navigation/favorites_navigation.dart';
import '../state/favorites_state.dart';
import 'favorites_product_grid.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onRetry,
    required this.onRemove,
    required this.onClearAll,
  });

  final FavoritesState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final ValueChanged<Favorite> onRemove;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.isEmpty) {
      return const AppLoading.page(message: 'Loading favorites…');
    }

    if (state.hasFailed && state.isEmpty) {
      return AppErrorState(
        title: 'Could not load favorites',
        message: state.errorMessage ?? 'Please try again.',
        onRetry: onRetry,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
        children: [
          if (state.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.md,
                AppSpacing.screenHorizontal,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${state.items.length} saved item(s)',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  AppButton(
                    label: 'Clear all',
                    variant: AppButtonVariant.text,
                    onPressed: onClearAll,
                    isExpanded: false,
                    height: 40,
                  ),
                ],
              ),
            ),
          if (state.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
              child: AppEmptyState(
                title: 'No favorites yet',
                message:
                    'Tap the heart on a product to save it here for later.',
                illustrationAsset: AppAssets.emptyFavorites,
                icon: Icons.favorite_border_rounded,
                actionLabel: 'Browse Home',
                onAction: () => FavoritesNavigation.openHome(context),
              ),
            )
          else
            FavoritesProductGrid(items: state.items, onRemove: onRemove),
        ],
      ),
    );
  }
}
