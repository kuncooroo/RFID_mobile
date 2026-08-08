import 'package:flutter/material.dart';

/// Kutuku corner radius tokens from the Figma UI kit.
abstract final class AppRadius {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double pill = 999;
  static const double full = 999;

  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlAll = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius xxxlAll = BorderRadius.all(Radius.circular(xxxl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));

  /// Product / promo image cards.
  static const BorderRadius card = xlAll;

  /// Text fields and search bars.
  static const BorderRadius input = lgAll;

  /// Primary and social buttons.
  static const BorderRadius button = BorderRadius.all(Radius.circular(xxl));

  /// Sort / filter / location chips.
  static const BorderRadius chip = pillAll;

  /// Bottom sheet top corners.
  static const BorderRadius bottomSheet = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );

  /// Product detail content panel top corners.
  static const BorderRadius detailSheet = BorderRadius.vertical(
    top: Radius.circular(xxxl),
  );

  /// Settings list tiles.
  static const BorderRadius settingsTile = lgAll;

  /// Avatars, color swatches, favorite FAB.
  static const BorderRadius avatar = fullAll;
}
