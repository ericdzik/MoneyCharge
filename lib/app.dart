import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/constants/app_colors.dart';
import 'package:locacharge/core/constants/app_routes.dart';
import 'package:locacharge/core/theme/app_theme.dart';
import 'package:locacharge/core/utils/route_guards.dart';
import 'package:locacharge/features/admin/screens/ad_screen.dart';
import 'package:locacharge/features/admin/screens/admin_dashboard_screen.dart';
import 'package:locacharge/features/admin/screens/manage_ads_screen.dart';
import 'package:locacharge/features/admin/screens/pending_verifications_screen.dart';
import 'package:locacharge/features/merchant/models/merchant_auth_model.dart';
import 'package:locacharge/features/merchant/screens/edit_merchant_profile_screen.dart';
import 'package:locacharge/features/merchant/screens/merchant_dashboard_screen.dart';
import 'package:locacharge/features/merchant/screens/merchant_profile_screen.dart';
import 'package:locacharge/features/merchant/screens/merchant_register_screen.dart';
import 'package:locacharge/features/merchant/screens/merchant_reviews_screen.dart';
import 'package:locacharge/features/user/screens/about_screen.dart';
import 'package:locacharge/features/user/screens/edit_user_profile_screen.dart';
import 'package:locacharge/features/user/screens/favorites_screen.dart';
import 'package:locacharge/features/user/screens/forgot_password_screen.dart';
import 'package:locacharge/features/user/screens/help_and_support_screen.dart';
import 'package:locacharge/features/user/screens/home_screen.dart';
import 'package:locacharge/features/user/screens/list_view_screen.dart';
import 'package:locacharge/features/user/screens/merchant_detail_screen.dart';
import 'package:locacharge/features/user/screens/notifications_screen.dart';
import 'package:locacharge/features/user/screens/privacy_screen.dart';
import 'package:locacharge/features/user/screens/promotions_screen.dart';
import 'package:locacharge/features/user/screens/user_login_screen.dart';
import 'package:locacharge/features/user/screens/user_profile_screen.dart';
import 'package:locacharge/features/user/screens/user_register_screen.dart';
import 'package:locacharge/providers/ad_provider.dart';
import 'package:locacharge/providers/auth_provider.dart';
import 'package:locacharge/providers/favorite_merchant_provider.dart';
import 'package:locacharge/providers/location_provider.dart';
import 'package:locacharge/providers/merchant_provider.dart';
import 'package:locacharge/providers/theme_provider.dart';
import 'package:locacharge/providers/transaction_provider.dart';
import 'package:locacharge/services/navigation_service.dart';
import 'package:locacharge/services/notification_service.dart';

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
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => MerchantProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteMerchantProvider()),
        ChangeNotifierProvider(create: (_) => AdProvider()),
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
        return const HomeScreen();
      case UserType.merchant:
        return const MerchantDashboardScreen();
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
          builder: (_) =>
              RouteGuards.requireUserType(const HomeScreen(), UserType.user),
        );

      case AppRoutes.listView:
        return MaterialPageRoute(
          builder: (_) => RouteGuards.requireUserType(
            const ListViewScreen(),
            UserType.user,
          ),
        );
      case AppRoutes.merchantDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => RouteGuards.requireUserType(
            MerchantDetailScreen(merchant: args?['merchant']),
            UserType.user,
          ),
        );

      case AppRoutes.userProfile:
        return MaterialPageRoute(
          builder: (_) => RouteGuards.requireUserType(
            const UserProfileScreen(),
            UserType.user,
          ),
        );

      case AppRoutes.favorites:
        return MaterialPageRoute(
          builder: (_) => RouteGuards.requireUserType(
            const FavoritesScreen(),
            UserType.user,
          ),
        );

      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (_) => RouteGuards.requireUserType(
            const EditUserProfileScreen(),
            UserType.user,
          ),
        );

      // Routes marchand
      case AppRoutes.merchantDashboard:
        return MaterialPageRoute(
          builder: (_) => RouteGuards.requireUserType(
            const MerchantDashboardScreen(),
            UserType.merchant,
          ),
        );

      case AppRoutes.merchantReviews:
        final args = settings.arguments as Map<String, dynamic>?;
        final merchantId = args?['merchantId'] as String;
        return MaterialPageRoute(
          builder: (_) => RouteGuards.requireUserType(
            MerchantReviewsScreen(merchantId: merchantId),
            UserType.merchant,
          ),
        );

      case AppRoutes.editMerchantProfile:
        final merchant = settings.arguments as MerchantAuthModel;
        return MaterialPageRoute(
          builder: (_) => RouteGuards.requireUserType(
            EditMerchantProfileScreen(merchant: merchant),
            UserType.merchant,
          ),
        );

      case AppRoutes.merchantProfile:
        return MaterialPageRoute(
          builder: (_) => RouteGuards.requireUserType(
            const MerchantProfileScreen(),
            UserType.merchant,
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
          builder: (_) => RouteGuards.requireUserType(
            const AdminDashboardScreen(),
            UserType.admin,
          ),
        );

      case AppRoutes.adminPendingVerifications:
        final args = settings.arguments as Map<String, dynamic>?;
        final pendingMerchants =
            args?['merchants'] as List<MerchantAuthModel>? ?? [];
        return MaterialPageRoute(
          builder: (_) => RouteGuards.requireUserType(
            PendingVerificationsScreen(pendingMerchants: pendingMerchants),
            UserType.admin,
          ),
        );

      case AppRoutes.adminAds:
        return MaterialPageRoute(
          builder: (_) => RouteGuards.requireUserType(
            const ManageAdsScreen(),
            UserType.admin,
          ),
        );

      case AppRoutes.adminAddAd:
        return MaterialPageRoute(
          builder: (_) =>
              RouteGuards.requireUserType(const AdScreen(), UserType.admin),
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
      appBar: AppBar(title: const Text('Page non trouvée')),
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
