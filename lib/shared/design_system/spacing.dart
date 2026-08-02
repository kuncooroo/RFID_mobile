/// Kutuku spacing scale (4-pt base) from the Figma layout rhythm.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double massive = 48;

  /// Horizontal screen padding used across most Kutuku screens.
  static const double screenHorizontal = 20;

  /// Vertical screen padding for content sections.
  static const double screenVertical = 16;

  /// Gap between major sections (e.g. carousel → product grid).
  static const double section = 24;

  /// Gap between cards in a list.
  static const double listItem = 12;

  /// Gap between items in a 2-column product grid.
  static const double grid = 16;

  /// Internal padding for standard cards.
  static const double card = 16;

  /// Internal padding for compact chips / pills.
  static const double chip = 12;

  /// Bottom safe content inset above bottom navigation / sticky CTA.
  static const double bottomContent = 24;
}
