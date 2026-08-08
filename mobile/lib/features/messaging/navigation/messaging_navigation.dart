import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../models/conversation.dart';

/// Messaging feature navigation helpers.
abstract final class MessagingNavigation {
  static void goToMessages(BuildContext context) {
    context.push(AppRoutes.messages);
  }

  static void pop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  static void openThread(BuildContext context, Conversation conversation) {
    context.push(AppRoutes.messageDetailPath(conversation.id));
  }

  static void openThreadById(BuildContext context, String threadId) {
    context.push(AppRoutes.messageDetailPath(threadId));
  }

  static void openNotifications(BuildContext context) {
    context.push(AppRoutes.notifications);
  }

  static void openCart(BuildContext context) {
    context.push(AppRoutes.cart);
  }

  static void openHome(BuildContext context) {
    context.go(AppRoutes.home);
  }
}
