import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/design_system/colors.dart';
import '../navigation/checkout_navigation.dart';
import '../providers/checkout_providers.dart';
import '../widgets/checkout_success_view.dart';

class CheckoutSuccessPage extends ConsumerWidget {
  const CheckoutSuccessPage({super.key, this.orderId});

  final String? orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queryOrderId = GoRouterState.of(context).uri.queryParameters['orderId'];
    final resolvedOrderId = orderId ?? queryOrderId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CheckoutSuccessView(
          orderId: resolvedOrderId,
          onViewOrder: () {
            ref.read(checkoutControllerProvider.notifier).resetPlacedOrder();
            if (resolvedOrderId != null) {
              CheckoutNavigation.openOrderTrack(context, resolvedOrderId);
            } else {
              CheckoutNavigation.openOrders(context);
            }
          },
          onBackToHome: () {
            ref.read(checkoutControllerProvider.notifier).resetPlacedOrder();
            CheckoutNavigation.openHome(context);
          },
        ),
      ),
    );
  }
}
