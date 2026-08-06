import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../models/notification.dart';

/// Notification center navigation helpers.
abstract final class NotificationsNavigation {
  static void open(BuildContext context) {
    context.push(AppRoutes.notifications);
  }

  static void pop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  static void openHome(BuildContext context) {
    context.go(AppRoutes.home);
  }

  /// Routes a notification tap to the related feature screen when possible.
  static void openNotification(BuildContext context, AppNotification item) {
    final type = item.referenceType ?? item.type.name;
    final id = item.referenceId;

    switch (type) {
      case 'order':
        if (id != null && id.isNotEmpty) {
          context.push(AppRoutes.orderTrackPath(id));
          return;
        }
        context.go(AppRoutes.orders);
        return;
      case 'chat':
        if (id != null && id.isNotEmpty) {
          context.push(AppRoutes.messageDetailPath(id));
          return;
        }
        context.push(AppRoutes.messages);
        return;
      case 'promo':
        context.go(AppRoutes.home);
        return;
      case 'payment':
        if (id != null && id.isNotEmpty) {
          context.push(AppRoutes.orderTrackPath(id));
          return;
        }
        return;
      default:
        return;
    }
  }
}
