import 'package:flutter/material.dart';

/// Fixed spacing tokens (no device-class scaling).
abstract final class AppSpacing {
  static const xxs = 8.0;
  static const xs = 16.0;
  static const sm = 24.0;
  static const md = 32.0;
  static const lg = 40.0;
  static const xl = 48.0;
  static const xxl = 64.0;
  static const hero = 80.0;

  static double pagePadding(BuildContext context) => 24;

  static double maxContentWidth(BuildContext context) => 920;

  static double maxReadableWidth(BuildContext context) => 640;

  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.aspectRatio > 1.15;
  }

  static bool isCompactHeight(BuildContext context) => false;

  static bool isNarrow(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 720;

  /// Kept for call-site compatibility — returns [base] unchanged.
  static double scale(BuildContext context, double base) => base;

  /// Kept for call-site compatibility — returns [base] unchanged.
  static double vGap(
    BuildContext context,
    double base, {
    double min = 8,
    double max = 64,
  }) =>
      base;

  static double primaryButtonHeight(BuildContext context) => 56;

  static double secondaryButtonHeight(BuildContext context) => 52;
}
