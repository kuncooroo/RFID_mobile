import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../messaging/providers/messaging_providers.dart';
import '../../product/models/product.dart';
import '../models/store.dart';

/// Store feature navigation helpers.
abstract final class StoreNavigation {
  static void openStore(BuildContext context, {required String storeId}) {
    context.push(AppRoutes.storeDetailPath(storeId));
  }

  static void openStoreFrom(BuildContext context, Store store) {
    openStore(context, storeId: store.id);
  }

  static void openProduct(BuildContext context, Product product) {
    context.push(AppRoutes.productDetailPath(product.id));
  }

  static void openCart(BuildContext context) {
    context.push(AppRoutes.cart);
  }

  static void openMessages(BuildContext context) {
    context.push(AppRoutes.messages);
  }

  static Future<void> openStoreMessage(
    BuildContext context,
    WidgetRef ref, {
    required String storeId,
    required String storeName,
    String? avatarUrl,
  }) async {
    final conversation = await ref
        .read(messagingControllerProvider.notifier)
        .openStoreConversation(
          storeId: storeId,
          storeName: storeName,
          avatarUrl: avatarUrl,
        );
    if (!context.mounted) return;
    if (conversation == null) {
      openMessages(context);
      return;
    }
    context.push(AppRoutes.messageDetailPath(conversation.id));
  }

  static void openSearch(BuildContext context) {
    context.push(AppRoutes.search);
  }

  static void pop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }
}
