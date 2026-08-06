import 'package:flutter/material.dart';

import '../../../shared/design_system/app_assets.dart';
import '../../../shared/design_system/colors.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../models/notification.dart';
import '../navigation/notifications_navigation.dart';
import '../state/notifications_state.dart';
import 'notification_tile.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onRetry,
    required this.onTapNotification,
  });

  final NotificationsState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final ValueChanged<AppNotification> onTapNotification;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.isEmpty) {
      return const AppLoading.page(message: 'Loading notifications…');
    }

    if (state.hasFailed && state.isEmpty) {
      return AppErrorState(
        title: 'Could not load notifications',
        message: state.errorMessage ?? 'Please try again.',
        onRetry: onRetry,
      );
    }

    if (state.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: AppEmptyState(
                title: 'No notifications',
                message:
                    'Updates about orders, chats, and offers will show up here.',
                illustrationAsset: AppAssets.emptyNotifications,
                icon: Icons.notifications_none_rounded,
                actionLabel: 'Browse Home',
                onAction: () => NotificationsNavigation.openHome(context),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.items.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.divider),
        itemBuilder: (context, index) {
          final item = state.items[index];
          return NotificationTile(
            notification: item,
            onTap: () => onTapNotification(item),
          );
        },
      ),
    );
  }
}
