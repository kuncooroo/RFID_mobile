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
    final size = MediaQuery.sizeOf(context);
    if (isLandscape(context)) {
      return size.shortestSide < 600 ? 16.0 : 24.0;
    }
    if (size.width >= 1100) return 48;
    if (size.width >= 720) return 32;
    if (size.width < 400) return 16;
    return 24;
  }

  /// Outer shell max width (welcome / large canvases).
  static double maxContentWidth(BuildContext context) {
    if (isLandscape(context)) return 980;
    final width = MediaQuery.sizeOf(context).width;
    if (width < 420) return width;
    return 920;
  }

  /// Forms / status copy — keep readable line length on wide screens.
  static double maxReadableWidth(BuildContext context) {
    if (isLandscape(context)) return 720;
    return 640;
  }

  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.aspectRatio > 1.15;
  }

  static bool isCompactHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).height < 760;
  }

  static bool isNarrow(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 720;
  }

  /// Scale a base size from shortest side, clamped for kiosk + phones.
  static double scale(BuildContext context, double base) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final factor = (shortest / 720).clamp(0.72, 1.25);
    return base * factor;
  }

  /// Vertical gap that shrinks on short / landscape screens.
  static double vGap(
    BuildContext context,
    double base, {
    double min = 8,
    double max = 64,
  }) {
    final height = MediaQuery.sizeOf(context).height;
    final factor = isLandscape(context)
        ? 0.65
        : (height / 900).clamp(0.7, 1.15);
    return (base * factor).clamp(min, max);
  }

  static double primaryButtonHeight(BuildContext context) =>
      scale(context, 58).clamp(52.0, 64.0);

  static double secondaryButtonHeight(BuildContext context) =>
      scale(context, 52).clamp(48.0, 58.0);
}
