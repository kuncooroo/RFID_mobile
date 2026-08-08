import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../shell/providers/shell_providers.dart';
import '../models/notification.dart';
import '../navigation/notifications_navigation.dart';
import '../providers/notifications_providers.dart';
import '../widgets/notifications_view.dart';

/// Notification center (Figma `1:59`).
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
      ref.read(notificationsControllerProvider.notifier).load();
    });
  }

  Future<void> _onTapNotification(AppNotification item) async {
    await ref.read(notificationsControllerProvider.notifier).markRead(item.id);
    await ref.read(shellControllerProvider.notifier).refresh();
    if (!mounted) return;
    NotificationsNavigation.openNotification(context, item);
  }

  Future<void> _markAllRead() async {
    await ref.read(notificationsControllerProvider.notifier).markAllRead();
    await ref.read(shellControllerProvider.notifier).refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);
    final hasUnread = state.unreadCount > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => NotificationsNavigation.pop(context),
        ),
        title: Text('Notifications', style: AppTextStyles.headlineSmall),
        centerTitle: false,
        actions: [
          if (hasUnread)
            AppButton(
              label: 'Mark all read',
              variant: AppButtonVariant.text,
              isExpanded: false,
              height: 40,
              onPressed: _markAllRead,
            ),
        ],
      ),
      body: NotificationsView(
        state: state,
        onRefresh: () async {
          await controller.refresh();
          await ref.read(shellControllerProvider.notifier).refresh();
        },
        onRetry: controller.load,
        onTapNotification: _onTapNotification,
      ),
    );
  }
}
