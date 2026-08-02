import 'package:flutter/material.dart';

import '../../../shared/design_system/app_assets.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../models/history.dart';
import '../models/order.dart';
import '../navigation/orders_navigation.dart';
import '../state/orders_state.dart';
import 'order_card.dart';
import 'orders_segment_tabs.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onRetry,
    required this.onSegmentChanged,
    this.onOpenHistoryPage,
  });

  final OrdersState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final ValueChanged<OrdersSegment> onSegmentChanged;
  final VoidCallback? onOpenHistoryPage;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.feed.isEmpty) {
      return const AppLoading.page(message: 'Loading orders…');
    }

    if (state.hasFailed && state.feed.isEmpty) {
      return AppErrorState(
        title: 'Could not load orders',
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
          const SizedBox(height: AppSpacing.md),
          OrdersSegmentTabs(
            segment: state.segment,
            onChanged: onSegmentChanged,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (state.segment == OrdersSegment.active)
            _ActiveList(orders: state.feed.activeOrders)
          else
            _HistoryList(
              items: state.feed.history,
              onSeeAll: onOpenHistoryPage,
            ),
        ],
      ),
    );
  }
}

class _ActiveList extends StatelessWidget {
  const _ActiveList({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
        child: AppEmptyState(
          title: 'No active orders',
          message: 'When you place an order, you can track it here.',
          illustrationAsset: AppAssets.emptyOrders,
          icon: Icons.local_shipping_outlined,
          actionLabel: 'Browse Home',
          onAction: () => OrdersNavigation.openHome(context),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        children: [
          for (final order in orders) ...[
            OrderCard(
              order: order,
              onTap: () => OrdersNavigation.openTrack(context, order),
              onTrack: () => OrdersNavigation.openTrack(context, order),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.items, this.onSeeAll});

  final List<History> items;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
        child: AppEmptyState(
          title: 'No order history',
          message: 'Completed and cancelled orders will appear here.',
          illustrationAsset: AppAssets.emptyOrders,
          icon: Icons.receipt_long_outlined,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        children: [
          if (onSeeAll != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onSeeAll,
                child: const Text('See all history'),
              ),
            ),
          for (final item in items) ...[
            HistoryOrderCard(
              item: item,
              onTap: () => OrdersNavigation.openHistoryItem(context, item),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}
