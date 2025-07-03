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
import 'features/user/screens/map_view_screen.dart' hide Container;
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
import 'features/merchant/screens/edit_merchant_profile_screen.dart'; // AJOUTÉ

// Import des écrans admin
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'dart:async'; // Ajout pour StreamSubscription (bien que non utilisé directement avec addListener)


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

      case AppRoutes.editMerchantProfile: // AJOUTÉ
        return MaterialPageRoute(
          builder: (_) => RouteGuards.requireUserType(
            const EditMerchantProfileScreen(),
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


// ... autres imports ... // Note: les autres imports sont déjà en haut du fichier.

// Écran de démarrage
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VoidCallback? _authListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      _authListener = () {
        if (!authProvider.isLoading) {
          if (mounted) {
            _navigateToNextScreen(authProvider);
          }
          // Le listener est retiré dans dispose ou après la première exécution réussie
        }
      };

      if (!authProvider.isLoading) {
        _navigateToNextScreen(authProvider);
      } else {
        authProvider.addListener(_authListener!);
      }
    });
  }

  @override
  void dispose() {
    if (_authListener != null) {
      // Tentative de retrait du listener s'il a été ajouté.
      // Cela nécessite que authProvider soit accessible ou que le listener soit stocké
      // d'une manière qui permette son retrait sans référence directe à l'instance de AuthProvider
      // si elle n'est plus accessible de manière fiable ici (bien que Provider.of devrait fonctionner).
      // Pour plus de sûreté, on peut vérifier si le provider est toujours accessible.
      try {
         if (mounted) { // Vérifier si le widget est toujours monté pour accéder au contexte
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            authProvider.removeListener(_authListener!);
         } else {
            // Si le widget n'est plus monté, il est possible que le listener ait déjà été retiré
            // ou que le contexte ne soit plus valide. Il est plus sûr de ne rien faire ou juste nullifier.
         }
      } catch (e) {
        print("[SplashScreen dispose] Error removing listener: $e. Listener might have been already removed or context is invalid.");
      }
       _authListener = null; // S'assurer qu'il est nullifié pour éviter des appels futurs.
    }
    super.dispose();
  }

  void _navigateToNextScreen(AuthProvider authProvider) {
    // Retirer le listener ici pour s'assurer qu'il ne s'exécute qu'une fois pour la navigation
    if (_authListener != null) {
      // Il est plus sûr de retirer le listener via le provider si possible
      // et si on a encore une référence valide au provider.
      // Cependant, authProvider est passé en argument, donc on peut l'utiliser.
      try {
        authProvider.removeListener(_authListener!);
      } catch (e) {
        print("[SplashScreen _navigateToNextScreen] Error removing listener: $e");
      }
      _authListener = null;
    }

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      print('-----------------------------------------------------');
      print('[SplashScreen._navigateToNextScreen] Checking auth state...');
      print('[SplashScreen] isAuthenticated: ${authProvider.isAuthenticated}');
      print('[SplashScreen] userType from AuthProvider: ${authProvider.userType}');
      print('[SplashScreen] isLoading: ${authProvider.isLoading}');
      print('[SplashScreen] error: ${authProvider.error}');

      if (authProvider.isAuthenticated) {
        final defaultRoute = RouteGuards.getDefaultRouteForUserType(
          authProvider.userType,
        );
        print('[SplashScreen] User authenticated. Determined defaultRoute: $defaultRoute for userType: ${authProvider.userType}');
        Navigator.pushReplacementNamed(context, defaultRoute);
      } else {
        print('[SplashScreen] User NOT authenticated or userType is unknown (or error). Navigating to login.');
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
      print('-----------------------------------------------------');
    });
  }

  @override
  Widget build(BuildContext context) {
// La première définition (plus simple) de SplashScreen et _SplashScreenState est supprimée.
// Seule cette version (avec _authListener) est conservée.
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
