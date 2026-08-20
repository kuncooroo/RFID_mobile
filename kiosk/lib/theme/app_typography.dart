import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

abstract final class AppTypography {
  static TextTheme textTheme(BuildContext context) {
    final display = AppSpacing.scale(context, 48);
    final heading = AppSpacing.scale(context, 32);
    final subhead = AppSpacing.scale(context, 22);
    final body = AppSpacing.scale(context, 18);
    final caption = AppSpacing.scale(context, 14);

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: display,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: AppColors.text,
        letterSpacing: -0.8,
      ),
      headlineLarge: TextStyle(
        fontSize: heading,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.text,
        letterSpacing: -0.4,
      ),
      headlineMedium: TextStyle(
        fontSize: heading * 0.88,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.text,
      ),
      titleLarge: TextStyle(
        fontSize: subhead,
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: AppColors.text,
      ),
      titleMedium: TextStyle(
        fontSize: body,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: AppColors.text,
      ),
      bodyLarge: TextStyle(
        fontSize: body,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.text,
      ),
      bodyMedium: TextStyle(
        fontSize: body * 0.92,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: body,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
      labelSmall: TextStyle(
        fontSize: caption,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      ),
    );
  }
}
