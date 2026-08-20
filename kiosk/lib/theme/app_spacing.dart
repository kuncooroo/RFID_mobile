import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const xxs = 8.0;
  static const xs = 16.0;
  static const sm = 24.0;
  static const md = 32.0;
  static const lg = 40.0;
  static const xl = 48.0;
  static const xxl = 64.0;
  static const hero = 80.0;

  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1100) return 48;
    if (width >= 720) return 32;
    return 24;
  }

  static double maxContentWidth(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (size.aspectRatio > 1.15) return 920;
    return 820;
  }

  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.aspectRatio > 1.15;
  }

  static double scale(BuildContext context, double base) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final factor = (shortest / 720).clamp(0.82, 1.25);
    return base * factor;
  }
}
