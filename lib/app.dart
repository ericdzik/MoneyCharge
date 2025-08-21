import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_routes.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/route_guards.dart';
import 'providers/auth_provider.dart';
import 'providers/location_provider.dart';
import 'providers/merchant_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/favorite_merchant_provider.dart'; // Ajout du FavoriteMerchantProvider
import 'providers/ad_provider.dart';

// Import des écrans utilisateur
import 'features/user/screens/home_screen.dart';
import 'features/user/screens/list_view_screen.dart';
import 'features/user/screens/map_view_screen.dart' hide Container;
import 'features/user/screens/merchant_detail_screen.dart';
import 'features/user/screens/user_login_screen.dart';
import 'features/user/screens/user_register_screen.dart';
import 'features/user/screens/forgot_password_screen.dart';
import 'core/widgets/auth_wrapper.dart';
import 'features/user/screens/user_profile_screen.dart';
import 'features/user/screens/rental_history_screen.dart';
import 'features/user/screens/favorites_screen.dart';
import 'features/user/screens/edit_user_profile_screen.dart';
import 'features/user/screens/splash_screen.dart';

// Import des écrans marchand
import 'features/merchant/screens/merchant_register_screen.dart';
import 'features/merchant/screens/merchant_dashboard_screen.dart';
import 'features/merchant/screens/balance_management_screen.dart';
import 'features/merchant/screens/edit_merchant_profile_screen.dart';

// Import des écrans admin
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/admin/screens/pending_verifications_screen.dart';
import 'features/admin/screens/ad_screen.dart';
import 'features/admin/screens/manage_ads_screen.dart';
import 'package:locacharge/features/merchant/screens/merchant_profile_screen.dart';
import 'package:locacharge/features/user/screens/notifications_screen.dart';
import 'package:locacharge/features/user/screens/help_and_support_screen.dart';
import 'package:locacharge/features/user/screens/privacy_screen.dart';
import 'package:locacharge/features/user/screens/about_screen.dart';
import 'package:locacharge/providers/theme_provider.dart';
import 'features/merchant/models/merchant_auth_model.dart';
import 'services/deep_link_service.dart';
import 'services/navigation_service.dart';

class LocaChargeApp extends StatefulWidget {
  const LocaChargeApp({super.key});

  @override
  State<LocaChargeApp> createState() => _LocaChargeAppState();
}

class _LocaChargeAppState extends State<LocaChargeApp> {
  final DeepLinkService _deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    _deepLinkService.initUniLinks();
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
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
        ChangeNotifierProvider(
          create: (_) => FavoriteMerchantProvider(),
        ), // Ajout ici
        ChangeNotifierProvider(create: (_) => AdProvider()),
      ],
      child: MaterialApp(
        title: 'Geo Money&Charge',
        navigatorKey: NavigationService.navigatorKey,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeProvider.themeMode,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const _SplashScreenLauncher());
      // Routes publiques
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

      // Routes utilisateur protégées
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

      case AppRoutes.mapView:
        return MaterialPageRoute(
          builder: (_) =>
              RouteGuards.requireUserType(const MapViewScreen(), UserType.user),
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

      case AppRoutes.rentalHistory:
        return MaterialPageRoute(
          builder: (_) => RouteGuards.requireUserType(
            const RentalHistoryScreen(),
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

      case AppRoutes.balanceManagement:
        return MaterialPageRoute(
          builder: (_) => RouteGuards.requireUserType(
            const BalanceManagementScreen(),
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

      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

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
          builder: (_) =>
              RouteGuards.requireUserType(const ManageAdsScreen(), UserType.admin),
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

class _SplashScreenLauncher extends StatefulWidget {
  const _SplashScreenLauncher({Key? key}) : super(key: key);

  @override
  State<_SplashScreenLauncher> createState() => _SplashScreenLauncherState();
}

class _SplashScreenLauncherState extends State<_SplashScreenLauncher> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthWrapper()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
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
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}
