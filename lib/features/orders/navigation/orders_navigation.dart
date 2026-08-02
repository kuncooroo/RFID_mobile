import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../models/history.dart';
import '../models/order.dart';

/// My Order feature navigation helpers.
abstract final class OrdersNavigation {
  static void goToOrders(BuildContext context) {
    context.go(AppRoutes.orders);
  }

  static void openHistory(BuildContext context) {
    context.push(AppRoutes.orderHistory);
  }

  static void openTrack(BuildContext context, Order order) {
    context.push(AppRoutes.orderTrackPath(order.id));
  }

  static void openTrackById(BuildContext context, String orderId) {
    context.push(AppRoutes.orderTrackPath(orderId));
  }

  static void openHistoryItem(BuildContext context, History item) {
    context.push(AppRoutes.orderTrackPath(item.orderId));
  }

  static void openHome(BuildContext context) {
    context.go(AppRoutes.home);
  }

  static void openProduct(BuildContext context, String productId) {
    context.push(AppRoutes.productDetailPath(productId));
  }
}
