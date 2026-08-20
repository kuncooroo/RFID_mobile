import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const small = 12.0;
  static const medium = 16.0;
  static const large = 24.0;
  static const hero = 32.0;
  static const pill = 999.0;

  static final sm = BorderRadius.circular(small);
  static final md = BorderRadius.circular(medium);
  static final lg = BorderRadius.circular(large);
  static final xl = BorderRadius.circular(hero);
}
