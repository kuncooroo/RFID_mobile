import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../providers/shell_providers.dart';
import '../widgets/shell_notification_tile.dart';

/// Notifications screen opened from shell chrome (root navigator).
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(shellNotificationsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(shellNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Notifications', style: AppTextStyles.headlineSmall),
        actions: [
          AppButton(
            label: 'Mark all read',
            variant: AppButtonVariant.text,
            isExpanded: false,
            height: 40,
            onPressed: () =>
                ref.read(shellNotificationsProvider.notifier).markAllRead(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const AppLoading.page(message: 'Loading notifications…'),
        error: (error, _) => AppErrorState(
          title: 'Could not load notifications',
          message: error.toString(),
          onRetry: () => ref.read(shellNotificationsProvider.notifier).load(),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const AppEmptyState(
              title: 'No notifications',
              message: 'Updates about orders and offers will show up here.',
              icon: Icons.notifications_none_rounded,
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(shellNotificationsProvider.notifier).load(),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final item = items[index];
                return ShellNotificationTile(
                  notification: item,
                  onTap: () => ref
                      .read(shellNotificationsProvider.notifier)
                      .markRead(item.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
