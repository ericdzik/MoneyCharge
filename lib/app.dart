import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/constants/app_colors.dart';
import 'package:locacharge/core/constants/app_routes.dart';
import 'package:locacharge/core/theme/app_theme.dart';

import 'package:locacharge/core/security/permission_provider.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';
import 'package:locacharge/features/admin/screens/ad_screen.dart';
import 'package:locacharge/features/admin/screens/admin_dashboard_screen.dart';
import 'package:locacharge/features/admin/screens/manage_ads_screen.dart';
import 'package:locacharge/features/admin/screens/pending_verifications_screen.dart';
import 'package:locacharge/features/auth/models/merchant_auth_model.dart';
// edit_merchant_profile_screen.dart supprimé - utiliser edit_user_profile_screen.dart unifié
import 'package:locacharge/core/security/permission_guard.dart';
import 'package:locacharge/core/security/rbac_constants.dart';
import 'package:locacharge/features/merchant/screens/merchant_card_screen.dart';
import 'package:locacharge/features/auth/screens/merchant_register_screen.dart';
import 'package:locacharge/features/merchant/screens/merchant_reviews_screen.dart';
import 'package:locacharge/features/merchant/screens/stock_management_screen.dart';
import 'package:locacharge/features/merchant/screens/sales_screen.dart';
import 'package:locacharge/features/merchant/screens/create_invoice_screen.dart';
import 'package:locacharge/features/merchant/models/invoice_model.dart';
import 'package:locacharge/features/user/screens/about_screen.dart';
import 'package:locacharge/features/user/screens/advertisement_detail_screen.dart';
import 'package:locacharge/features/user/screens/edit_user_profile_screen.dart';
import 'package:locacharge/features/auth/screens/forgot_password_screen.dart';
import 'package:locacharge/features/user/screens/help_and_support_screen.dart';
import 'package:locacharge/features/user/screens/merchant_detail_screen.dart';
import 'package:locacharge/features/user/screens/notifications_screen.dart';
import 'package:locacharge/features/user/screens/privacy_screen.dart';
import 'package:locacharge/features/user/screens/promotions_screen.dart';
import 'package:locacharge/features/auth/screens/user_login_screen.dart';
// user profile screen imported by specific screens where needed
import 'package:locacharge/features/auth/screens/user_register_screen.dart';
import 'package:locacharge/providers/ad_provider.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';
import 'package:locacharge/providers/favorite_merchant_provider.dart';
import 'package:locacharge/features/user/models/merchant_model.dart';
import 'package:locacharge/providers/location_provider.dart';
import 'package:locacharge/providers/merchant_provider.dart';
import 'package:locacharge/providers/theme_provider.dart';
import 'package:locacharge/providers/transaction_provider.dart';

import 'package:locacharge/features/shared/screens/main_screen.dart';

import 'package:locacharge/providers/invoice_provider.dart';
import 'package:locacharge/services/navigation_service.dart';
import 'package:locacharge/services/notification_service.dart';
import 'package:locacharge/features/user/services/feed_manager.dart';

class LocaChargeApp extends StatefulWidget {
  const LocaChargeApp({super.key});

  @override
  State<LocaChargeApp> createState() => _LocaChargeAppState();
}

class _LocaChargeAppState extends State<LocaChargeApp> {
  @override
  void initState() {
    super.initState();
    NotificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, PermissionProvider>(
          create: (context) => PermissionProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, authProvider, permissionProvider) =>
              permissionProvider!..update(authProvider),
        ),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProxyProvider<LocationProvider, MerchantProvider>(
          create: (context) => MerchantProvider(null),
          update: (context, locationProvider, merchantProvider) =>
              merchantProvider!..update(locationProvider),
        ),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteMerchantProvider()),
        ChangeNotifierProvider(create: (_) => AdProvider()),
        ChangeNotifierProvider(create: (_) => FeedManager()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Geo Money&Charge',
            navigatorKey: NavigationService.navigatorKey,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            // Route initiale basée sur l'état d'authentification
            home: _getInitialScreen(authProvider),
            onGenerateRoute: (settings) =>
                _generateRoute(settings, authProvider),
          );
        },
      ),
    );
  }

  // Détermine l'écran initial en fonction de l'état d'authentification
  Widget _getInitialScreen(AuthProvider authProvider) {
    if (authProvider.isLoading) {
      // Afficher un écran de chargement pendant la vérification
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!authProvider.isAuthenticated) {
      return const UnifiedLoginScreen();
    }

    // Rediriger vers l'écran approprié selon le type d'utilisateur
    switch (authProvider.userType) {
      case UserType.user:
        return const MainScreen(initialIndex: 0);
      case UserType.merchant:
        // Merchant lands on Dashboard (Index 2) by default, or Home (Index 0)?
        // Use Index 2 (Dashboard) to preserve business flow
        return const MainScreen(initialIndex: 2);
      case UserType.admin:
        return const AdminDashboardScreen();
      default:
        return const UnifiedLoginScreen();
    }
  }

  Route<dynamic> _generateRoute(
    RouteSettings settings,
    AuthProvider authProvider,
  ) {
    // Routes publiques (accessibles sans authentification)
    if (_isPublicRoute(settings.name)) {
      return _getPublicRoute(settings);
    }

    // Si l'utilisateur n'est pas authentifié, rediriger vers login
    if (!authProvider.isAuthenticated) {
      return MaterialPageRoute(
        builder: (_) => const UnifiedLoginScreen(),
        settings: settings,
      );
    }

    // Routes protégées
    return _getProtectedRoute(settings);
  }

  // Vérifie si la route est publique
  bool _isPublicRoute(String? routeName) {
    const publicRoutes = [
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.merchantRegister,
      AppRoutes.forgotPassword,
    ];
    return publicRoutes.contains(routeName);
  }

  // Retourne les routes publiques
  Route<dynamic> _getPublicRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const UnifiedLoginScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const UserRegisterScreen());

      case AppRoutes.merchantRegister:
        return MaterialPageRoute(
          builder: (_) => const MerchantRegisterScreen(),
        );

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      default:
        return MaterialPageRoute(builder: (_) => const UnifiedLoginScreen());
    }
  }

  // Retourne les routes protégées
  Route<dynamic> _getProtectedRoute(RouteSettings settings) {
    switch (settings.name) {
      // Routes utilisateur
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.viewHome,
            child: const MainScreen(initialIndex: 0),
          ),
        );

      case AppRoutes.mapView:
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.viewMarketplace,
            child: const MainScreen(initialIndex: 1),
          ),
        );

      case AppRoutes.listView:
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.viewMarketplace,
            // ListView is Index 2 for User.
            // For Merchant, Index 2 is Dashboard.
            // If Merchant accesses this route, MainScreen will show Dashboard if we pass 2.
            // So we might need a specific check or accept that this route leads to "List View equivalent" tab.
            child: const MainScreen(initialIndex: 2),
          ),
        );
      case AppRoutes.merchantDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final merchant = args?['merchant'] as Merchant?;
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.viewMarketplace,
            child: MerchantDetailScreen(merchant: merchant!),
          ),
        );

      case AppRoutes.advertisementDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final advertisement = args?['advertisement'];
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.viewMarketplace,
            child: AdvertisementDetailScreen(advertisement: advertisement),
          ),
        );

      case AppRoutes.userProfile:
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.viewUserProfile,
            child: const MainScreen(initialIndex: 4),
          ),
        );

      case AppRoutes.favorites:
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.viewFavorites,
            child: const MainScreen(initialIndex: 3),
          ),
        );

      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.editUserProfile,
            child: const EditUserProfileScreen(),
          ),
        );

      // Routes marchand
      case AppRoutes.merchantDashboard:
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.accessMerchantDashboard,
            child: const MainScreen(initialIndex: 2),
          ),
        );

      case AppRoutes.merchantCard:
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.manageBusinessProfile,
            child: const MerchantCardScreen(),
          ),
        );

      case AppRoutes.merchantReviews:
        final args = settings.arguments as Map<String, dynamic>?;
        final merchantId = args?['merchantId'] as String;
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.respondToReviews,
            child: MerchantReviewsScreen(merchantId: merchantId),
          ),
        );

      case AppRoutes.editMerchantProfile:
        // Utilise l'écran unifié qui détecte automatiquement le type (User/Merchant)
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.manageBusinessProfile,
            child: const EditUserProfileScreen(),
          ),
        );

      case AppRoutes.merchantProfile:
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.manageBusinessProfile,
            child: const MainScreen(initialIndex: 4), // Profile is Index 4
          ),
        );

      case AppRoutes.stockManagement:
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.manageStock,
            child: const StockManagementScreen(),
          ),
        );

      case AppRoutes.salesScreen:
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.viewSalesByType,
            child: const SalesScreen(),
          ),
        );

      case AppRoutes.createInvoice:
        final invoice = settings.arguments as InvoiceModel?;
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.createInvoice,
            child: CreateInvoiceScreen(invoice: invoice),
          ),
        );

      // Routes communes (accessibles à tous les utilisateurs authentifiés)
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case AppRoutes.promotions:
        return MaterialPageRoute(builder: (_) => const PromotionsScreen());

      case AppRoutes.help:
        return MaterialPageRoute(builder: (_) => const HelpAndSupportScreen());

      case AppRoutes.privacy:
        return MaterialPageRoute(builder: (_) => const PrivacyScreen());

      case AppRoutes.about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());

      // Routes admin
      case AppRoutes.adminDashboard:
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.accessAdminDashboard,
            child: const AdminDashboardScreen(),
          ),
        );

      case AppRoutes.adminPendingVerifications:
        final args = settings.arguments as Map<String, dynamic>?;
        final pendingMerchants =
            args?['merchants'] as List<MerchantAuthModel>? ?? [];
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.approveMerchants,
            child: PendingVerificationsScreen(
              pendingMerchants: pendingMerchants,
            ),
          ),
        );

      case AppRoutes.adminAds:
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.manageSystemAds,
            child: const ManageAdsScreen(),
          ),
        );

      case AppRoutes.adminAddAd:
        return MaterialPageRoute(
          builder: (routeContext) => PermissionGuard.check(
            context: routeContext,
            permission: AppPermission.manageSystemAds,
            child: const AdScreen(),
          ),
        );

      default:
        return MaterialPageRoute(builder: (_) => const NotFoundScreen());
    }
  }
}

// Écran 404
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Page non trouvée', showLogo: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Page non trouvée',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'La page que vous recherchez n\'existe pas.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              child: const Text('Retour à la connexion'),
            ),
          ],
        ),
      ),
    );
  }
}
