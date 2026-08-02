/// Central route path constants grouped by feature.
abstract final class AppRoutes {
  // --- Splash / bootstrap ---
  static const splash = '/splash';

  // --- Onboarding ---
  static const onboarding = '/onboarding';

  // --- Authentication ---
  static const auth = '/auth';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const registerSuccess = '/auth/register/success';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';

  // --- Main navigation (shell) ---
  static const dashboard = '/dashboard';

  /// Alias for the Home tab root (same path as [dashboard]).
  static const home = dashboard;
  static const orders = '/orders';
  static const favorites = '/favorites';
  static const profile = '/profile';

  // --- Home / catalog (nested under app) ---
  static const search = '/search';
  static const searchResults = '/search/results';
  static const category = '/category';

  // --- Store ---
  static const storeDetail = '/stores/:storeId';

  // --- Product ---
  static const productDetail = '/products/:productId';

  // --- Cart / checkout ---
  static const cart = '/cart';
  static const checkoutAddress = '/checkout/address';
  static const checkoutPayment = '/checkout/payment';
  static const checkoutPaymentMethods = '/checkout/payment-methods';
  static const checkoutAddCard = '/checkout/add-card';
  static const checkoutSuccess = '/checkout/success';

  // --- Orders (nested) ---
  static const orderHistory = '/orders/history';
  static const orderTrack = '/orders/:orderId/track';

  // --- Messaging ---
  static const messages = '/messages';
  static const messageDetail = '/messages/:threadId';

  // --- Notifications ---
  static const notifications = '/notifications';

  // --- Settings (nested under profile) ---
  static const settings = '/profile/settings';
  static const editProfile = '/profile/settings/edit-profile';
  static const changePassword = '/profile/settings/change-password';
  static const notificationSettings = '/profile/settings/notifications';
  static const security = '/profile/settings/security';
  static const language = '/profile/settings/language';
  static const helpSupport = '/profile/settings/help';
  static const legalPolicies = '/profile/settings/legal';

  // --- Unknown ---
  static const notFound = '/404';

  /// Public routes that never require authentication.
  static const publicRoutes = <String>{
    splash,
    onboarding,
    login,
    register,
    registerSuccess,
    forgotPassword,
    resetPassword,
    notFound,
  };

  static String storeDetailPath(String storeId) => '/stores/$storeId';

  static String productDetailPath(String productId) => '/products/$productId';

  static String orderTrackPath(String orderId) => '/orders/$orderId/track';

  static String messageDetailPath(String threadId) => '/messages/$threadId';

  static bool isPublic(String location) {
    final path = Uri.parse(location).path;
    if (publicRoutes.contains(path)) return true;
    if (path.startsWith('$auth/')) return true;
    return false;
  }
}
