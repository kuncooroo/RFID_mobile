import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/auth/presentation/register_success_page.dart';
import '../../features/auth/presentation/reset_password_page.dart';
import '../../features/cart/presentation/cart_page.dart';
import '../../features/catalog/presentation/category_page.dart';
import '../../features/checkout/presentation/add_card_page.dart';
import '../../features/checkout/presentation/address_page.dart';
import '../../features/checkout/presentation/checkout_success_page.dart';
import '../../features/checkout/presentation/payment_methods_page.dart';
import '../../features/checkout/presentation/payment_page.dart';
import '../../features/favorites/presentation/favorites_page.dart';
import '../../features/search/presentation/search_page.dart';
import '../../features/search/presentation/search_results_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/messaging/presentation/message_detail_page.dart';
import '../../features/messaging/presentation/messages_page.dart';
import '../../features/orders/presentation/order_history_page.dart';
import '../../features/orders/presentation/order_track_page.dart';
import '../../features/orders/presentation/orders_page.dart';
import '../../features/profile/presentation/change_password_page.dart';
import '../../features/profile/presentation/edit_profile_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/profile/presentation/settings_detail_pages.dart';
import '../../features/profile/presentation/settings_page.dart';
import '../../features/shell/presentation/notifications_page.dart';
import '../../features/shell/widgets/main_shell.dart';
import '../../features/splash/presentation/splash_page.dart';
import 'app_routes.dart';
import 'auth_session.dart';
import '../../features/product/presentation/product_detail_page.dart';
import '../../features/store/presentation/store_detail_page.dart';
import 'route_placeholder.dart'; // NotFoundPage

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _dashboardNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'dashboard',
);
final _ordersNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'orders');
final _favoritesNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'favorites',
);
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

/// Notifies [GoRouter] when auth session changes.
class _RouterAuthRefresh extends ChangeNotifier {
  _RouterAuthRefresh(this._ref) {
    _subscription = _ref.listen<AuthSessionState>(
      authSessionProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;
  late final ProviderSubscription<AuthSessionState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

String? _authRedirect(Ref ref, GoRouterState state) {
  final session = ref.read(authSessionProvider);
  final location = state.matchedLocation;
  final isPublic = AppRoutes.isPublic(location);
  final isSplash = location == AppRoutes.splash;
  final isOnboarding = location == AppRoutes.onboarding;
  final isAuthRoute = location.startsWith(AppRoutes.auth);

  if (session.isUnknown) {
    return isSplash ? null : AppRoutes.splash;
  }

  if (isSplash) {
    if (!session.hasSeenOnboarding) return AppRoutes.onboarding;
    return session.isAuthenticated
        ? AppRoutes.dashboard
        : (session.authEntryRoute ?? AppRoutes.login);
  }

  if (!session.hasSeenOnboarding && !isOnboarding) {
    return AppRoutes.onboarding;
  }

  if (session.hasSeenOnboarding && isOnboarding) {
    if (session.isAuthenticated) return AppRoutes.dashboard;
    return session.authEntryRoute ?? AppRoutes.login;
  }

  if (session.isUnauthenticated && !isPublic) {
    return AppRoutes.login;
  }

  if (session.isAuthenticated && (isAuthRoute || isOnboarding)) {
    return AppRoutes.dashboard;
  }

  return null;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterAuthRefresh(ref);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refresh,
    redirect: (context, state) => _authRedirect(ref, state),
    errorBuilder: (context, state) => NotFoundPage(uri: state.uri.toString()),
    routes: [
      // ─────────────────────────────────────────────
      // Splash
      // ─────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // ─────────────────────────────────────────────
      // Onboarding
      // ─────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // ─────────────────────────────────────────────
      // Authentication
      // ─────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.auth,
        redirect: (context, state) {
          if (state.uri.path == AppRoutes.auth) return AppRoutes.login;
          return null;
        },
        routes: [
          GoRoute(
            path: 'login',
            name: 'login',
            builder: (context, state) => const LoginPage(),
          ),
          GoRoute(
            path: 'register',
            name: 'register',
            builder: (context, state) => const RegisterPage(),
            routes: [
              GoRoute(
                path: 'success',
                name: 'registerSuccess',
                builder: (context, state) => const RegisterSuccessPage(),
              ),
            ],
          ),
          GoRoute(
            path: 'forgot-password',
            name: 'forgotPassword',
            builder: (context, state) => ForgotPasswordPage(
              initialIdentifier: state.uri.queryParameters['email'],
            ),
          ),
          GoRoute(
            path: 'reset-password',
            name: 'resetPassword',
            builder: (context, state) => ResetPasswordPage(
              initialIdentifier: state.uri.queryParameters['email'],
              token: state.uri.queryParameters['token'],
            ),
          ),
        ],
      ),

      // ─────────────────────────────────────────────
      // Main navigation (bottom tabs)
      // ─────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Dashboard / Home
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),

          // Orders
          StatefulShellBranch(
            navigatorKey: _ordersNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.orders,
                name: 'orders',
                builder: (context, state) => const OrdersPage(),
                routes: [
                  GoRoute(
                    path: 'history',
                    name: 'orderHistory',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const OrderHistoryPage(),
                  ),
                  GoRoute(
                    path: ':orderId/track',
                    name: 'orderTrack',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final orderId = state.pathParameters['orderId']!;
                      return OrderTrackPage(orderId: orderId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Favorites
          StatefulShellBranch(
            navigatorKey: _favoritesNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.favorites,
                name: 'favorites',
                builder: (context, state) => const FavoritesPage(),
              ),
            ],
          ),

          // Profile (+ nested settings)
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    name: 'settings',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const SettingsPage(),
                    routes: [
                      GoRoute(
                        path: 'edit-profile',
                        name: 'editProfile',
                        builder: (context, state) => const EditProfilePage(),
                      ),
                      GoRoute(
                        path: 'change-password',
                        name: 'changePassword',
                        builder: (context, state) => const ChangePasswordPage(),
                      ),
                      GoRoute(
                        path: 'notifications',
                        name: 'notificationSettings',
                        builder: (context, state) =>
                            const NotificationSettingsPage(),
                      ),
                      GoRoute(
                        path: 'security',
                        name: 'security',
                        builder: (context, state) => const SecurityPage(),
                      ),
                      GoRoute(
                        path: 'language',
                        name: 'language',
                        builder: (context, state) => const LanguagePage(),
                      ),
                      GoRoute(
                        path: 'help',
                        name: 'helpSupport',
                        builder: (context, state) => const HelpSupportPage(),
                      ),
                      GoRoute(
                        path: 'legal',
                        name: 'legalPolicies',
                        builder: (context, state) => const LegalPoliciesPage(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ─────────────────────────────────────────────
      // Catalog / Category
      // ─────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.category,
        name: 'category',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final categoryId = state.uri.queryParameters['id'];
          return CategoryPage(categoryId: categoryId);
        },
      ),

      // ─────────────────────────────────────────────
      // Search (feature stack, root navigator)
      // ─────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SearchPage(),
        routes: [
          GoRoute(
            path: 'results',
            name: 'searchResults',
            builder: (context, state) {
              final query = state.uri.queryParameters['q'] ?? '';
              return SearchResultsPage(initialQuery: query);
            },
          ),
        ],
      ),

      // ─────────────────────────────────────────────
      // Store
      // ─────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.storeDetail,
        name: 'storeDetail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final storeId = state.pathParameters['storeId']!;
          return StoreDetailPage(storeId: storeId);
        },
      ),

      // ─────────────────────────────────────────────
      // Product
      // ─────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.productDetail,
        name: 'productDetail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return ProductDetailPage(productId: productId);
        },
      ),

      // ─────────────────────────────────────────────
      // Cart / Checkout
      // ─────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.cart,
        name: 'cart',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: '/checkout',
        parentNavigatorKey: _rootNavigatorKey,
        redirect: (context, state) {
          if (state.uri.path == '/checkout') {
            return AppRoutes.checkoutAddress;
          }
          return null;
        },
        routes: [
          GoRoute(
            path: 'address',
            name: 'checkoutAddress',
            builder: (context, state) => const AddressPage(),
          ),
          GoRoute(
            path: 'payment',
            name: 'checkoutPayment',
            builder: (context, state) => const PaymentPage(),
          ),
          GoRoute(
            path: 'payment-methods',
            name: 'checkoutPaymentMethods',
            builder: (context, state) => const PaymentMethodsPage(),
          ),
          GoRoute(
            path: 'add-card',
            name: 'checkoutAddCard',
            builder: (context, state) => const AddCardPage(),
          ),
          GoRoute(
            path: 'success',
            name: 'checkoutSuccess',
            builder: (context, state) {
              final orderId = state.uri.queryParameters['orderId'];
              return CheckoutSuccessPage(orderId: orderId);
            },
          ),
        ],
      ),

      // ─────────────────────────────────────────────
      // Messaging
      // ─────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.messages,
        name: 'messages',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MessagesPage(),
        routes: [
          GoRoute(
            path: ':threadId',
            name: 'messageDetail',
            builder: (context, state) {
              final threadId = state.pathParameters['threadId']!;
              return MessageDetailPage(threadId: threadId);
            },
          ),
        ],
      ),

      // ─────────────────────────────────────────────
      // Notifications
      // ─────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsPage(),
      ),

      // ─────────────────────────────────────────────
      // Unknown route (explicit)
      // ─────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.notFound,
        name: 'notFound',
        builder: (context, state) =>
            NotFoundPage(uri: state.uri.queryParameters['from']),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
