import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../shell/navigation/shell_navigation.dart';
import '../../shell/providers/shell_providers.dart';
import '../../shell/widgets/shell_app_bar.dart';
import '../navigation/orders_navigation.dart';
import '../providers/orders_providers.dart';
import '../widgets/orders_view.dart';

/// My Order tab screen (shell branch root).
class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(ordersControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersControllerProvider);
    final controller = ref.read(ordersControllerProvider.notifier);
    final badges = ref.watch(
      shellControllerProvider.select((s) => s.badges),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ShellAppBar(
        title: 'My Order',
        unreadNotifications: badges.unreadNotifications,
        onNotifications: () => ShellNavigation.openNotifications(context),
        onCart: () => ShellNavigation.openCart(context),
      ),
      body: OrdersView(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.load,
        onSegmentChanged: controller.setSegment,
        onOpenHistoryPage: () => OrdersNavigation.openHistory(context),
      ),
    );
  }
}
