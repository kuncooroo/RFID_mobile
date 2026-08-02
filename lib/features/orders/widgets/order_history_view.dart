import 'package:flutter/material.dart';

import '../../../shared/design_system/app_assets.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../navigation/orders_navigation.dart';
import '../state/orders_state.dart';
import 'order_card.dart';

class OrderHistoryView extends StatelessWidget {
  const OrderHistoryView({
    super.key,
    required this.state,
    required this.onRetry,
  });

  final OrderHistoryState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const AppLoading.page(message: 'Loading history…');
    }

    if (state.hasFailed) {
      return AppErrorState(
        title: 'Could not load history',
        message: state.errorMessage ?? 'Please try again.',
        onRetry: onRetry,
      );
    }

    if (state.items.isEmpty) {
      return AppEmptyState(
        title: 'No order history',
        message: 'Your past orders will show up here.',
        illustrationAsset: AppAssets.emptyOrders,
        icon: Icons.receipt_long_outlined,
        actionLabel: 'Back to Orders',
        onAction: () => OrdersNavigation.goToOrders(context),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      itemCount: state.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final item = state.items[index];
        return HistoryOrderCard(
          item: item,
          onTap: () => OrdersNavigation.openHistoryItem(context, item),
        );
      },
    );
  }
}
