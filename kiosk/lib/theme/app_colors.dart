import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFF7FAFC);
  static const surface = Color(0xFFFFFFFF);
  /// Light blue brand (TapGo).
  static const primary = Color(0xFF4BA3F5);
  static const primaryDark = Color(0xFF2F86D6);
  static const text = Color(0xFF1F1F1F);
  static const textSecondary = Color(0xFF6B6B6B);
  static const textMuted = Color(0xFF7B7B7B);
  static const border = Color(0xFFE8E8E8);
  static const success = Color(0xFF22A06B);
  static const warning = Color(0xFFFF8500);
  static const error = Color(0xFFC94848);
  /// Neutral status (help / timeout).
  static const statusMuted = Color(0xFF8A8F96);

  static const muted = textMuted;
  static const danger = error;
  static const bg = background;
  static const panel = surface;
}
