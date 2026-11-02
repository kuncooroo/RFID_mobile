import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Shared Material 3 surface card for kiosk screens.
class SystemCard extends StatelessWidget {
  const SystemCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(32),
    this.elevation = 0,
    this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final double elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  /// Backward-compatible alias for a slightly raised card.
  const SystemCard.elevated({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(32),
    this.borderRadius,
    this.onTap,
  }) : elevation = 1;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.lg;
    final content = Padding(padding: padding, child: child);

    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: elevation,
        margin: EdgeInsets.zero,
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}
