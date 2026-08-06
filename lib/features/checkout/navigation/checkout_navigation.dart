import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';

/// Checkout feature navigation helpers.
abstract final class CheckoutNavigation {
  static void openAddress(BuildContext context) {
    context.push(AppRoutes.checkoutAddress);
  }

  static void openPayment(BuildContext context) {
    context.push(AppRoutes.checkoutPayment);
  }

  static void openPaymentMethods(BuildContext context) {
    context.push(AppRoutes.checkoutPaymentMethods);
  }

  static void openAddCard(BuildContext context) {
    context.push(AppRoutes.checkoutAddCard);
  }

  static void openSuccess(BuildContext context, {String? orderId}) {
    final uri = orderId == null
        ? AppRoutes.checkoutSuccess
        : '${AppRoutes.checkoutSuccess}?orderId=${Uri.encodeComponent(orderId)}';
    context.go(uri);
  }

  static void openOrderTrack(BuildContext context, String orderId) {
    context.go(AppRoutes.orderTrackPath(orderId));
  }

  static void openOrders(BuildContext context) {
    context.go(AppRoutes.orders);
  }

  static void openHome(BuildContext context) {
    context.go(AppRoutes.home);
  }

  static void pop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }
}
