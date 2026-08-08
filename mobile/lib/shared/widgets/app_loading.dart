import 'package:flutter/material.dart';

import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../design_system/text_styles.dart';

/// Inline or centered page loading indicator.
class AppLoading extends StatelessWidget {
  const AppLoading({
    super.key,
    this.size = 28,
    this.color,
    this.strokeWidth = 2.5,
  }) : message = null;

  /// Centered loading block for full page / section placeholders.
  const AppLoading.page({
    super.key,
    this.message,
    this.size = 36,
    this.color,
    this.strokeWidth = 3,
  });

  final double size;
  final Color? color;
  final double strokeWidth;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
      ),
    );

    if (message == null && size <= 28) {
      return indicator;
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          if (message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              message!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
