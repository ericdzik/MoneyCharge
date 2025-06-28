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

// Import des écrans utilisateur
import 'features/user/screens/home_screen.dart';
import 'features/user/screens/list_view_screen.dart';
import 'features/user/screens/map_view_screen.dart';
import 'features/user/screens/merchant_detail_screen.dart';
import 'features/user/screens/user_login_screen.dart';
import 'features/user/screens/user_register_screen.dart';
import 'features/user/screens/forgot_password_screen.dart';
import 'features/user/screens/user_profile_screen.dart';
import 'features/user/screens/rental_history_screen.dart';

// Import des écrans marchand
import 'features/merchant/screens/merchant_register_screen.dart';
import 'features/merchant/screens/merchant_dashboard_screen.dart';
import 'features/merchant/screens/balance_management_screen.dart';

// Import des écrans admin
import 'features/admin/screens/admin_dashboard_screen.dart';

class LocaChargeApp extends StatelessWidget {
  const LocaChargeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => MerchantProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'LocaCharge',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: (settings) {
          return _generateRoute(settings);
        },
      ),
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Routes publiques
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

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

      // Routes utilisateur (protégées)
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

      // Routes marchand (protégées)
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

      // Routes admin (protégées)
      case AppRoutes.adminDashboard:
        return MaterialPageRoute(
          builder: (_) => RouteGuards.requireUserType(
            const AdminDashboardScreen(),
            UserType.admin,
          ),
        );

      default:
        return MaterialPageRoute(builder: (_) => const NotFoundScreen());
    }
  }
}

// Écran de démarrage
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Simule un délai de chargement pour le splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Utiliser addPostFrameCallback pour s'assurer que le widget est monté
    // et que le contexte est valide pour Provider.of
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // Vérifier à nouveau après le callback
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // AuthProvider s'initialise maintenant dans son constructeur et écoute les authStateChanges.
      // Nous pouvons directement vérifier l'état ici après le délai du splash.
      if (authProvider.isAuthenticated) {
        final defaultRoute = RouteGuards.getDefaultRouteForUserType(
          authProvider.userType,
        );
        Navigator.pushReplacementNamed(context, defaultRoute);
      } else {
        // Si non authentifié, ou si le profil n'a pas encore été chargé (isLoading est true),
        // on pourrait attendre un peu plus ou aller directement au login.
        // Pour l'instant, on va au login si pas encore authentifié après le délai.
        // Une logique plus fine pourrait observer authProvider.isLoading.
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.onPrimary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.phone_android,
                color: AppColors.primary,
                size: 60,
              ),
            ),
            const SizedBox(height: 32),

            // Titre
            Text(
              'LocaCharge',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Sous-titre
            Text(
              'Location de chargeurs de téléphone',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 64),

            // Indicateur de chargement
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
            ),
          ],
        ),
      ),
    );
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
