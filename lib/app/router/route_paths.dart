class RoutePaths {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Customer Bottom Tabs
  static const String home = '/home';
  static const String explore = '/explore';
  static const String wishlist = '/wishlist';
  static const String cart = '/cart';
  static const String profile = '/profile';

  // Discovery & Shopping
  static const String search = '/search';
  static const String bookDetails = '/book/:id';
  static const String reviews = '/book/:id/reviews';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation/:orderId';

  // Orders & Account
  static const String orders = '/orders';
  static const String orderDetails = '/orders/:id';
  static const String editProfile = '/profile/edit';
  static const String addresses = '/profile/addresses';
  static const String addEditAddress = '/profile/addresses/edit';
  static const String paymentMethods = '/profile/payments';
  static const String addEditPayment = '/profile/payments/edit';

  // Administration
  static const String admin = '/admin';
  static const String adminBooks = '/admin/books';
  static const String adminAddEditBook = '/admin/books/edit';
  static const String adminOrders = '/admin/orders';
  static const String adminUsers = '/admin/users';
  static const String adminPromotions = '/admin/promotions';
  static const String adminPolicies = '/admin/policies';
  static const String terms = '/policies/terms';
  static const String privacy = '/policies/privacy';
  static const String adminSettings = '/admin/settings';
}
