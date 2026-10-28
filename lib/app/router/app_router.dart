import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/screens/add_edit_book_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/book_management_screen.dart';
import '../../features/admin/screens/order_management_screen.dart';
import '../../features/admin/screens/user_management_screen.dart';
import '../../features/admin/screens/store_settings_screen.dart';
import '../../features/authentication/screens/forgot_password_screen.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/onboarding_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/authentication/screens/splash_screen.dart';
import '../../features/book_details/screens/book_details_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/catalog/screens/catalog_screen.dart';
import '../../features/checkout/screens/checkout_screen.dart';
import '../../features/checkout/screens/order_confirmation_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/orders/screens/my_orders_screen.dart';
import '../../features/orders/screens/order_details_screen.dart';
import '../../features/profile/screens/add_edit_address_screen.dart';
import '../../features/profile/screens/add_edit_payment_screen.dart';
import '../../features/profile/screens/address_management_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/payment_methods_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/reviews/screens/reviews_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/wishlist/screens/wishlist_screen.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/premium_bottom_navigation.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(currentUserStreamProvider, (_, _) => refresh.value++);
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final path = state.uri.path;
      final signedIn = ref.read(firebaseAuthProvider).currentUser != null;
      final profileState = ref.read(currentUserStreamProvider);
      final profile = profileState.value;
      final authPage = [
        '/login',
        '/register',
        '/forgot-password',
        '/onboarding',
        '/',
      ].contains(path);
      final publicPage =
          authPage ||
          path == '/home' ||
          path == '/explore' ||
          path == '/search' ||
          path.startsWith('/book/');
      if (!signedIn && !publicPage) {
        return '/login?from=${Uri.encodeComponent(state.uri.toString())}';
      }
      if (path.startsWith('/admin') &&
          signedIn &&
          profile == null &&
          !profileState.hasError) {
        return null;
      }
      if (path.startsWith('/admin') && profile?.isAdmin != true) return '/home';
      if (signedIn && profile != null && authPage) {
        final from = state.uri.queryParameters['from'];
        return from != null &&
                from.startsWith('/') &&
                !from.startsWith('//') &&
                !from.startsWith('/login')
            ? from
            : '/home';
      }
      return null;
    },
    routes: [
      // Splash
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Auth
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Customer Bottom Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: Consumer(
              builder: (context, ref, child) {
                final cartAsync = ref.watch(cartStreamProvider);
                final cartCount =
                    cartAsync.value?.fold<int>(
                      0,
                      (sum, item) => sum + item.quantity,
                    ) ??
                    0;

                return PremiumBottomNavigation(
                  currentIndex: navigationShell.currentIndex,
                  cartItemCount: cartCount,
                  onTap: (index) {
                    navigationShell.goBranch(
                      index,
                      initialLocation: index == navigationShell.currentIndex,
                    );
                  },
                );
              },
            ),
          );
        },
        branches: [
          // 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // 1: Explore / Catalog
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const CatalogScreen(),
              ),
            ],
          ),
          // 2: Wishlist
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wishlist',
                builder: (context, state) => const WishlistScreen(),
              ),
            ],
          ),
          // 3: Cart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          // 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Search
      GoRoute(
        path: '/search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SearchScreen(),
      ),

      // Book Details & Reviews
      GoRoute(
        path: '/book/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BookDetailsScreen(bookId: id);
        },
      ),
      GoRoute(
        path: '/book/:id/reviews',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ReviewsScreen(bookId: id);
        },
      ),

      // Checkout & Order Confirmation
      GoRoute(
        path: '/checkout',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order-confirmation/:orderId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderConfirmationScreen(orderId: orderId);
        },
      ),

      // Orders
      GoRoute(
        path: '/orders',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MyOrdersScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrderDetailsScreen(orderId: id);
        },
      ),

      // Profile Sub-screens
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/addresses',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddressManagementScreen(),
      ),
      GoRoute(
        path: '/profile/addresses/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            AddEditAddressScreen(addressId: state.uri.queryParameters['id']),
      ),
      GoRoute(
        path: '/profile/payments',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: '/profile/payments/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddEditPaymentScreen(),
      ),

      // Admin Module
      GoRoute(
        path: '/admin',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/books',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BookManagementScreen(),
      ),
      GoRoute(
        path: '/admin/books/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return AddEditBookScreen(bookId: id);
        },
      ),
      GoRoute(
        path: '/admin/orders',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OrderManagementScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/admin/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const StoreSettingsScreen(),
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
