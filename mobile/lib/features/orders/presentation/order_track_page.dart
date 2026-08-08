import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/text_styles.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderTrackControllerProvider(widget.orderId));
    final controller =
        ref.read(orderTrackControllerProvider(widget.orderId).notifier);

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
    );
  }
}
