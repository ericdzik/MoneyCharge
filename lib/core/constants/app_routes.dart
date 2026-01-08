class AppRoutes {
  // Routes publiques
  static const String login = '/login';
  static const String register = '/register';
  static const String merchantRegister = '/merchant/register';
  static const String forgotPassword = '/forgot-password';

  // Routes utilisateur
  static const String home = '/home';
  static const String listView = '/list';
  static const String mapView = '/map';
  static const String merchantDetail = '/merchant-detail';
  static const String userProfile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String rentalHistory = '/rental-history';
  static const String favorites = '/favorites';
  static const String notifications = '/notifications';
  static const String promotions = '/promotions';
  static const String help = '/help';
  static const String privacy = '/privacy';
  static const String about = '/about';
  static const String advertisementDetail = '/advertisement-detail';

  // Routes marchand
  static const String merchantDashboard = '/merchant/dashboard';
  static const String merchantCard = '/merchant/card';
  static const String stockManagement = '/merchant/stock';
  static const String salesScreen = '/merchant/sales';
  static const String createInvoice = '/merchant/invoice/create';
  static const String invoicesList = '/merchant/invoices';
  static const String merchantProfile = '/merchant/profile';
  static const String merchantAnalytics = '/merchant/analytics';
  static const String merchantReviews = '/merchant/reviews';
  static const String premiumSubscription = '/merchant/premium';

  // Routes admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminMerchants = '/admin/merchants';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminSettings = '/admin/settings';
  static const String adminPendingVerifications = '/admin/pending-verifications';
  static const String editMerchantProfile = '/merchant/edit-profile';
  static const String adminAds = '/admin/ads';
  static const String adminAddAd = '/admin/ads/add';
}
