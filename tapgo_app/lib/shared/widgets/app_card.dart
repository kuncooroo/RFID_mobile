import 'package:flutter/material.dart';

import '../design_system/colors.dart';
import '../design_system/radius.dart';
import '../design_system/spacing.dart';

enum AppCardVariant { elevated, outlined, filled, flat }

/// Surface container used for products, settings rows, orders, and promos.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.variant = AppCardVariant.elevated,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final AppCardVariant variant;
  final double? width;
  final double? height;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.card;
    final background =
        color ??
        switch (variant) {
          AppCardVariant.filled => AppColors.surfaceMuted,
          _ => AppColors.surface,
        };

    final decoration = BoxDecoration(
      color: background,
      borderRadius: radius,
      border: variant == AppCardVariant.outlined
          ? Border.all(color: AppColors.border)
          : null,
      boxShadow: variant == AppCardVariant.elevated
          ? const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ]
          : null,
    );

    final content = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpacing.card),
      decoration: decoration,
      clipBehavior: clipBehavior,
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: radius, child: content),
    );
  }
}
