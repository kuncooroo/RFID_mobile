import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../navigation/cart_navigation.dart';
import '../providers/cart_providers.dart';
import '../widgets/cart_view.dart';

/// My Cart screen (root navigator).
class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(cartControllerProvider.notifier).load();
    });
  }

  Future<void> _confirmRemove(String itemId) async {
    final confirmed = await showAppDialog(
      context: context,
      title: 'Remove item?',
      message: 'This product will be removed from your cart.',
      confirmLabel: 'Remove',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    await ref.read(cartControllerProvider.notifier).removeItem(itemId);
  }

  void _onCheckout() {
    final state = ref.read(cartControllerProvider);
    if (!state.hasSelection) return;
    CartNavigation.openCheckout(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('My Cart', style: AppTextStyles.headlineSmall),
      ),
      body: CartView(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.load,
        onToggleSelect: controller.toggleSelect,
        onSelectAll: controller.selectAll,
        onQtyChanged: controller.updateQty,
        onRemove: _confirmRemove,
        onCheckout: _onCheckout,
        onOpenProduct: (productId) =>
            CartNavigation.openProduct(context, productId),
      ),
    );
  }
}
