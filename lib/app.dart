import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/route_guards.dart';
import 'core/widgets/auth_wrapper.dart';
import 'providers/auth_provider.dart';
import 'providers/location_provider.dart';
import 'providers/merchant_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/favorite_merchant_provider.dart';
import 'providers/ad_provider.dart';
import 'providers/theme_provider.dart';

import 'features/user/screens/screens.dart';
import 'features/merchant/screens/screens.dart';
import 'features/admin/screens/screens.dart';
import 'features/merchant/models/merchant_auth_model.dart';

class LocaChargeApp extends StatelessWidget {
  const LocaChargeApp({super.key});

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
      child: MaterialApp(
        title: 'Geo Money&Charge',
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
    final userRoute = _generateUserRoute(settings);
    if (userRoute != null) return userRoute;

    final merchantRoute = _generateMerchantRoute(settings);
    if (merchantRoute != null) return merchantRoute;

    final adminRoute = _generateAdminRoute(settings);
    if (adminRoute != null) return adminRoute;

    final publicRoute = _generatePublicRoute(settings);
    if (publicRoute != null) return publicRoute;

    return MaterialPageRoute(builder: (_) => const NotFoundScreen());
  }

  Route<dynamic>? _generateUserRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return _buildProtectedRoute(const HomeScreen(), UserType.user);
      case AppRoutes.listView:
        return _buildProtectedRoute(const ListViewScreen(), UserType.user);
      case AppRoutes.mapView:
        return _buildProtectedRoute(const MapViewScreen(), UserType.user);
      case AppRoutes.merchantDetail:
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          return _buildProtectedRoute(
              MerchantDetailScreen(merchant: args['merchant']), UserType.user);
        }
        return _buildErrorRoute();
      case AppRoutes.userProfile:
        return _buildProtectedRoute(const UserProfileScreen(), UserType.user);
      case AppRoutes.rentalHistory:
        return _buildProtectedRoute(const RentalHistoryScreen(), UserType.user);
      case AppRoutes.favorites:
        return _buildProtectedRoute(const FavoritesScreen(), UserType.user);
      case AppRoutes.editProfile:
        return _buildProtectedRoute(const EditUserProfileScreen(), UserType.user);
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case AppRoutes.help:
        return MaterialPageRoute(builder: (_) => const HelpAndSupportScreen());
      case AppRoutes.privacy:
        return MaterialPageRoute(builder: (_) => const PrivacyScreen());
      case AppRoutes.about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      default:
        return null;
    }
  }

  Route<dynamic>? _generateMerchantRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.merchantDashboard:
        return _buildProtectedRoute(const MerchantDashboardScreen(), UserType.merchant);
      case AppRoutes.balanceManagement:
        return _buildProtectedRoute(const BalanceManagementScreen(), UserType.merchant);
      case AppRoutes.editMerchantProfile:
        final args = settings.arguments;
        if (args is MerchantAuthModel) {
          return _buildProtectedRoute(
              EditMerchantProfileScreen(merchant: args), UserType.merchant);
        }
        return _buildErrorRoute();
      case AppRoutes.merchantProfile:
        return _buildProtectedRoute(const MerchantProfileScreen(), UserType.merchant);
      default:
        return null;
    }
  }

  Route<dynamic>? _generateAdminRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.adminDashboard:
        return _buildProtectedRoute(const AdminDashboardScreen(), UserType.admin);
      case AppRoutes.adminPendingVerifications:
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          final pendingMerchants =
              args['merchants'] as List<MerchantAuthModel>? ?? [];
          return _buildProtectedRoute(
              PendingVerificationsScreen(pendingMerchants: pendingMerchants),
              UserType.admin);
        }
        return _buildErrorRoute();
      case AppRoutes.adminAds:
        return _buildProtectedRoute(const AdScreen(), UserType.admin);
      default:
        return null;
    }
  }

  Route<dynamic>? _generatePublicRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const _SplashScreenLauncher());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const UnifiedLoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const UserRegisterScreen());
      case AppRoutes.merchantRegister:
        return MaterialPageRoute(builder: (_) => const MerchantRegisterScreen());
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      default:
        return null;
    }
  }

  MaterialPageRoute _buildProtectedRoute(Widget child, UserType userType) {
    return MaterialPageRoute(
      builder: (_) => RouteGuards.requireUserType(child, userType),
    );
  }

  MaterialPageRoute _buildErrorRoute() {
    return MaterialPageRoute(builder: (_) => const NotFoundScreen());
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
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const AuthWrapper()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}

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
            const Icon(Icons.error_outline, size: 80),
            const SizedBox(height: 16),
            Text(
              'Page non trouvée',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'La page que vous recherchez n\'existe pas.',
              style: Theme.of(context).textTheme.bodyLarge,
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
