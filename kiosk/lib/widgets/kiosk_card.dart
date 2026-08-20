import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

class KioskCard extends StatelessWidget {
  const KioskCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(32),
    this.elevated = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lg,
        boxShadow: elevated ? AppShadows.elevated : AppShadows.card,
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
