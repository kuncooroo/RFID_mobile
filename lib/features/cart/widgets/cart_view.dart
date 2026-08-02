import 'package:flutter/material.dart';

import '../../../shared/design_system/app_assets.dart';
import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../models/cart.dart';
import '../navigation/cart_navigation.dart';
import '../state/cart_state.dart';
import 'cart_checkout_bar.dart';
import 'cart_item_tile.dart';
import 'cart_select_all_bar.dart';

class CartView extends StatelessWidget {
  const CartView({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onRetry,
    required this.onToggleSelect,
    required this.onSelectAll,
    required this.onQtyChanged,
    required this.onRemove,
    required this.onCheckout,
    required this.onOpenProduct,
  });

  final CartState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final ValueChanged<String> onToggleSelect;
  final ValueChanged<bool> onSelectAll;
  final void Function(String itemId, int qty) onQtyChanged;
  final ValueChanged<String> onRemove;
  final VoidCallback onCheckout;
  final ValueChanged<String> onOpenProduct;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.isEmpty) {
      return const AppLoading.page(message: 'Loading cart…');
    }

    if (state.hasFailed && state.isEmpty) {
      return AppErrorState(
        title: 'Could not load cart',
        message: state.errorMessage ?? 'Please try again.',
        onRetry: onRetry,
      );
    }

    if (state.isEmpty) {
      return AppEmptyState(
        title: 'Your cart is empty',
        message: 'Browse products and add items to your cart.',
        illustrationAsset: AppAssets.emptyCart,
        icon: Icons.shopping_cart_outlined,
        actionLabel: 'Back to Home',
        onAction: () => CartNavigation.openHome(context),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.md,
                AppSpacing.screenHorizontal,
                AppSpacing.xxl,
              ),
              children: [
                CartSelectAllBar(
                  allSelected: state.allSelected,
                  onToggleAll: onSelectAll,
                  itemCount: state.cart.itemCount,
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  variant: AppCardVariant.outlined,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    children: _buildItemTiles(state.cart.items),
                  ),
                ),
              ],
            ),
          ),
        ),
        CartCheckoutBar(
          total: state.selectedSubtotal,
          selectedCount: state.selectedCount,
          enabled: state.hasSelection,
          onCheckout: onCheckout,
        ),
      ],
    );
  }

  List<Widget> _buildItemTiles(List<CartItem> items) {
    final tiles = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      tiles.add(
        CartItemTile(
          item: item,
          onToggleSelect: () => onToggleSelect(item.id),
          onQtyChanged: (qty) => onQtyChanged(item.id, qty),
          onTap: () => onOpenProduct(item.productId),
          onDelete: () => onRemove(item.id),
        ),
      );
      if (i < items.length - 1) {
        tiles.add(const Divider(height: 1, color: AppColors.divider));
      }
    }
    return tiles;
  }
}
