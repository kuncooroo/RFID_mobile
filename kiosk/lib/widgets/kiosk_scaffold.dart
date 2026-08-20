import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class KioskScaffold extends StatelessWidget {
  const KioskScaffold({
    super.key,
    required this.child,
    this.dark = false,
  });

  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final padding = AppSpacing.pagePadding(context);
    final maxWidth = AppSpacing.maxContentWidth(context);
    return ColoredBox(
      color: dark ? const Color(0xFF111111) : AppColors.background,
      child: SafeArea(
        child: Theme(
          data: Theme.of(context).copyWith(
            textTheme: AppTypography.textTheme(context).apply(
              bodyColor: dark ? Colors.white : AppColors.text,
              displayColor: dark ? Colors.white : AppColors.text,
            ),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: padding * 0.7,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
