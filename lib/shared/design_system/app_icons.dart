/// SVG icon asset paths for the Kutuku icon set.
///
/// Place matching SVG files under `assets/icons/`.
/// Consume with `flutter_svg` (e.g. `SvgPicture.asset(AppIcons.home)`).
abstract final class AppIcons {
  static const String _base = 'assets/icons';

  // Bottom navigation
  static const String home = '$_base/home.svg';
  static const String homeFilled = '$_base/home_filled.svg';
  static const String order = '$_base/order.svg';
  static const String orderFilled = '$_base/order_filled.svg';
  static const String favorite = '$_base/favorite.svg';
  static const String favoriteFilled = '$_base/favorite_filled.svg';
  static const String profile = '$_base/profile.svg';
  static const String profileFilled = '$_base/profile_filled.svg';

  // App bar / actions
  static const String search = '$_base/search.svg';
  static const String notification = '$_base/notification.svg';
  static const String cart = '$_base/cart.svg';
  static const String bag = '$_base/bag.svg';
  static const String back = '$_base/back.svg';
  static const String close = '$_base/close.svg';
  static const String more = '$_base/more.svg';
  static const String filter = '$_base/filter.svg';
  static const String share = '$_base/share.svg';

  // Form
  static const String mail = '$_base/mail.svg';
  static const String lock = '$_base/lock.svg';
  static const String eye = '$_base/eye.svg';
  static const String eyeOff = '$_base/eye_off.svg';
  static const String user = '$_base/user.svg';
  static const String phone = '$_base/phone.svg';

  // Commerce
  static const String star = '$_base/star.svg';
  static const String starFilled = '$_base/star_filled.svg';
  static const String heart = '$_base/heart.svg';
  static const String heartFilled = '$_base/heart_filled.svg';
  static const String verified = '$_base/verified.svg';
  static const String plus = '$_base/plus.svg';
  static const String minus = '$_base/minus.svg';
  static const String check = '$_base/check.svg';
  static const String trash = '$_base/trash.svg';

  // Settings
  static const String editProfile = '$_base/edit_profile.svg';
  static const String changePassword = '$_base/change_password.svg';
  static const String security = '$_base/security.svg';
  static const String language = '$_base/language.svg';
  static const String help = '$_base/help.svg';
  static const String legal = '$_base/legal.svg';
  static const String logout = '$_base/logout.svg';
  static const String chevronRight = '$_base/chevron_right.svg';
  static const String chevronDown = '$_base/chevron_down.svg';

  // Social
  static const String google = '$_base/google.svg';
  static const String facebook = '$_base/facebook.svg';

  // Status / misc
  static const String success = '$_base/success.svg';
  static const String warning = '$_base/warning.svg';
  static const String info = '$_base/info.svg';
  static const String empty = '$_base/empty.svg';
  static const String location = '$_base/location.svg';
  static const String payment = '$_base/payment.svg';
  static const String truck = '$_base/truck.svg';
  static const String message = '$_base/message.svg';
}
