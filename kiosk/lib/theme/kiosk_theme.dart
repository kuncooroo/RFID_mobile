import 'package:flutter/material.dart';

abstract final class KioskColors {
  static const primary = Color(0xFF514EB7);
  static const primaryDark = Color(0xFF2F2C7A);
  static const bg = Color(0xFF0F1020);
  static const panel = Color(0xFF1A1B33);
  static const text = Color(0xFFFFFFFF);
  static const muted = Color(0xFFB7B8D6);
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);
}

ThemeData buildKioskTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: KioskColors.primary,
      brightness: Brightness.dark,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: KioskColors.bg,
    textTheme: base.textTheme.apply(
      bodyColor: KioskColors.text,
      displayColor: KioskColors.text,
    ),
  );
}
