import 'package:flutter/material.dart';

/// Kutuku color tokens derived from the Figma UI kit.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF514EB7);
  static const Color primaryDark = Color(0xFF4542B2);
  static const Color primaryLight = Color(0xFFBAB9E2);
  static const Color primarySoft = Color(0xFFE8E7F7);

  // Neutrals
  static const Color black = Color(0xFF21201E);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF9F9FB);
  static const Color scrim = Color(0x9921211E);

  // Text
  static const Color textPrimary = Color(0xFF21201E);
  static const Color textSecondary = Color(0xFF7D7F8A);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBEBFC4);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textLink = primary;

  // Borders & dividers
  static const Color border = Color(0xFFE7E8EC);
  static const Color borderStrong = Color(0xFFD1D2D6);
  static const Color divider = Color(0xFFF0F0F3);

  // Semantic
  static const Color success = Color(0xFF2E7D32);
  static const Color successSoft = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF5A623);
  static const Color warningSoft = Color(0xFFFFF8E1);
  static const Color danger = Color(0xFFE53935);
  static const Color dangerSoft = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1E88E5);
  static const Color infoSoft = Color(0xFFE3F2FD);

  // Feedback accents
  static const Color rating = Color(0xFFFFC107);
  static const Color badge = Color(0xFFE53935);
  static const Color favorite = Color(0xFFE53935);
  static const Color verified = Color(0xFF1E88E5);

  // Input
  static const Color inputFill = Color(0xFFF5F5F7);
  static const Color inputBorder = Color(0xFFE7E8EC);
  static const Color inputBorderFocused = primary;
  static const Color inputPlaceholder = Color(0xFF9E9E9E);

  // Navigation
  static const Color navActive = primary;
  static const Color navInactive = Color(0xFF9E9E9E);
  static const Color bottomNavBackground = white;

  // Overlay / sheet
  static const Color bottomSheetHandle = Color(0xFFD1D2D6);
  static const Color chipSelected = primary;
  static const Color chipUnselected = Color(0xFFF5F5F7);

  // Shadows (tint)
  static const Color shadow = Color(0x1A21201E);
}
