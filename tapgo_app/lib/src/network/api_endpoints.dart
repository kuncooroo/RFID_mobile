/// Central Laravel REST path constants (relative to [AppConfig.apiBaseUrl]).
abstract final class ApiEndpoints {
  static const register = '/register';
  static const login = '/login';
  static const logout = '/logout';
  static const refresh = '/refresh';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';

  static const user = '/user';
  static const userProfile = '/user/profile';
  static const userPassword = '/user/password';
  static const userSettings = '/user/settings';
  static const languages = '/languages';

  static const home = '/home';
  static const categories = '/categories';
  static const products = '/products';
  static const reviews = '/reviews';
  static const favorites = '/favorites';
  static const cart = '/cart';
  static const cartItems = '/cart/items';
  static const cartSelectAll = '/cart/select-all';
  static const addresses = '/addresses';
  static const paymentMethods = '/payment-methods';
  static const checkout = '/checkout';
  static const orders = '/orders';
  static const ordersHistory = '/orders/history';
  static const conversations = '/conversations';
  static const notifications = '/notifications';
  static const notificationsReadAll = '/notifications/read-all';
  static const rfidVerify = '/rfid/verify';

  static String category(String id) => '/categories/$id';
  static String categoryProducts(String id) => '/categories/$id/products';
  static String product(String id) => '/products/$id';
  static String productReviews(String id) => '/products/$id/reviews';
  static String store(String id) => '/stores/$id';
  static String storeProducts(String id) => '/stores/$id/products';
  static String favoriteProduct(String productId) => '/favorites/$productId';
  static String cartItem(String id) => '/cart/items/$id';
  static String address(String id) => '/addresses/$id';
  static String paymentMethod(String id) => '/payment-methods/$id';
  static String order(String id) => '/orders/$id';
  static String orderTrack(String id) => '/orders/$id/track';
  static String orderCancel(String id) => '/orders/$id/cancel';
  static String conversationMessages(String id) =>
      '/conversations/$id/messages';
  static String conversationRead(String id) => '/conversations/$id/read';
  static String notificationRead(String id) => '/notifications/$id/read';
  static String rfidVerification(String id) => '/rfid/verifications/$id';
}
