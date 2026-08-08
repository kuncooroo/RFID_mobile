/// Image and illustration asset paths for Kutuku.
///
/// Place files under the matching `assets/` folders.
abstract final class AppAssets {
  static const String _images = 'assets/images';
  static const String _illustrations = 'assets/illustrations';
  static const String _fonts = 'assets/fonts';

  // Brand
  static const String logo = '$_images/logo.png';
  static const String logoMark = '$_images/logo_mark.png';
  static const String splash = '$_images/splash.png';
  static const String statisticsHero = '$_illustrations/onboarding_1.png';

  // Placeholders
  static const String placeholderProduct = '$_images/placeholder_product.png';
  static const String placeholderAvatar = '$_images/placeholder_avatar.png';
  static const String placeholderStore = '$_images/placeholder_store.png';
  static const String placeholderBanner = '$_images/placeholder_banner.png';

  // Onboarding illustrations
  static const String onboarding1 = '$_illustrations/onboarding_1.png';
  static const String onboarding2 = '$_illustrations/onboarding_2.png';
  static const String onboarding3 = '$_illustrations/onboarding_3.png';

  // Empty / success states
  static const String emptyCart = '$_illustrations/empty_cart.png';
  static const String emptyFavorites = '$_illustrations/empty_favorites.png';
  static const String emptyOrders = '$_illustrations/empty_orders.png';
  static const String emptySearch = '$_illustrations/empty_search.png';
  static const String emptyMessages = '$_illustrations/empty_messages.png';
  static const String emptyNotifications =
      '$_illustrations/empty_notifications.png';
  static const String successPayment = '$_illustrations/success_payment.png';
  static const String successRegister = '$_illustrations/success_register.png';

  // Fonts (for release bundling with google_fonts / pubspec)
  static const String fontPlusJakartaSansRegular =
      '$_fonts/PlusJakartaSans-Regular.ttf';
  static const String fontPlusJakartaSansMedium =
      '$_fonts/PlusJakartaSans-Medium.ttf';
  static const String fontPlusJakartaSansSemiBold =
      '$_fonts/PlusJakartaSans-SemiBold.ttf';
  static const String fontPlusJakartaSansBold =
      '$_fonts/PlusJakartaSans-Bold.ttf';

  /// All raster/illustration folders registered in [pubspec.yaml].
  static const List<String> assetFolders = [
    'assets/icons/',
    'assets/images/',
    'assets/illustrations/',
  ];
}
