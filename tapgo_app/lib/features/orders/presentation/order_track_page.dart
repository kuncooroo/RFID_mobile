import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../navigation/orders_navigation.dart';
import '../providers/orders_providers.dart';
import '../widgets/order_track_view.dart';

/// Order Track screen (Figma `1:55`).
class OrderTrackPage extends ConsumerStatefulWidget {
  const OrderTrackPage({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderTrackPage> createState() => _OrderTrackPageState();
}

class _OrderTrackPageState extends ConsumerState<OrderTrackPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(orderTrackControllerProvider(widget.orderId).notifier).load();
    });
  }

  Future<void> _copyTracking(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tracking number copied')),
    );
  }

  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel order?'),
        content: const Text(
          'This cannot be undone. Refunds follow your payment method policy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final ok = await ref
        .read(orderTrackControllerProvider(widget.orderId).notifier)
        .cancel();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Order cancelled'
              : (ref
                      .read(orderTrackControllerProvider(widget.orderId))
                      .errorMessage ??
                  'Could not cancel order'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderTrackControllerProvider(widget.orderId));
    final controller =
        ref.read(orderTrackControllerProvider(widget.orderId).notifier);
    final canCancel = state.order?.canCancel == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => OrdersNavigation.pop(context),
        ),
        title: Text('Order Track', style: AppTextStyles.headlineSmall),
        centerTitle: false,
      ),
      body: OrderTrackView(
        state: state,
        onRetry: controller.load,
        onRefresh: controller.refresh,
        onCopyTrackingNumber: _copyTracking,
        onOpenProduct: (productId) =>
            OrdersNavigation.openProduct(context, productId),
      ),
      bottomNavigationBar: !canCancel
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: AppButton(
                  label: 'Cancel Order',
                  variant: AppButtonVariant.outline,
                  onPressed: state.isCancelling ? null : _cancelOrder,
                  isLoading: state.isCancelling,
                ),
              ),
            ),
    );
  }
}
