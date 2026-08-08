import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// Kutuku typography based on Plus Jakarta Sans from the Figma kit.
abstract final class AppTextStyles {
  static String? get _fontFamily => GoogleFonts.plusJakartaSans().fontFamily;

  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double height = 1.4,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Display
  static TextStyle get displayLarge => _base(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static TextStyle get displayMedium => _base(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Headings / screen titles
  static TextStyle get headlineLarge => _base(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get headlineMedium => _base(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static TextStyle get headlineSmall => _base(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  // Titles
  static TextStyle get titleLarge => _base(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => _base(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleSmall => _base(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body
  static TextStyle get bodyLarge => _base(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => _base(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => _base(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Labels / buttons / meta
  static TextStyle get labelLarge => _base(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelMedium => _base(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelSmall => _base(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Semantic aliases used across Kutuku screens
  static TextStyle get screenTitle => headlineLarge;

  static TextStyle get sectionTitle => headlineSmall;

  static TextStyle get productName => titleMedium;

  static TextStyle get productBrand =>
      bodySmall.copyWith(color: AppColors.textSecondary);

  static TextStyle get price =>
      titleMedium.copyWith(fontWeight: FontWeight.w700);

  static TextStyle get priceLarge => headlineMedium.copyWith(
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get button =>
      labelLarge.copyWith(color: AppColors.textOnPrimary);

  static TextStyle get buttonSecondary => labelLarge;

  static TextStyle get link => labelMedium.copyWith(color: AppColors.textLink);

  static TextStyle get inputLabel => titleSmall;

  static TextStyle get inputText => bodyMedium;

  static TextStyle get inputPlaceholder =>
      bodyMedium.copyWith(color: AppColors.inputPlaceholder);

  static TextStyle get caption => bodySmall;

  static TextStyle get bottomNavLabel =>
      labelSmall.copyWith(fontSize: 11, height: 1.2);

  static TextStyle get chip => labelMedium;

  /// Material 3 [TextTheme] mapped to Kutuku styles.
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: headlineLarge,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );

  /// Exposes the resolved font family for rare custom uses.
  static String? get fontFamily => _fontFamily;
}
