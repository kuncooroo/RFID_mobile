import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/text_styles.dart';
import '../providers/orders_providers.dart';
import '../widgets/order_track_view.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderTrackControllerProvider(widget.orderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Order Track', style: AppTextStyles.headlineSmall),
      ),
      body: OrderTrackView(
        state: state,
        onRetry: () => ref
            .read(orderTrackControllerProvider(widget.orderId).notifier)
            .load(),
      ),
    );
  }
}
