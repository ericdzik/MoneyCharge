import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../constants/app_routes.dart';
import '../../features/user/screens/unified_login_screen.dart';
import '../utils/route_guards.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Affiche un écran de chargement global si l'authentification est en cours.
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si l'utilisateur est authentifié, le rediriger.
        if (authProvider.isAuthenticated) {
          // Utilise addPostFrameCallback pour éviter les erreurs de build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final userType = authProvider.userType;
            final route = RouteGuards.getDefaultRouteForUserType(userType);
            // pushAndRemoveUntil est plus robuste pour vider la pile de navigation.
            Navigator.of(context).pushNamedAndRemoveUntil(route, (Route<dynamic> route) => false);
          });
          // Affiche un écran de chargement pendant la redirection.
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Sinon, afficher l'écran de connexion.
        // Si une erreur est survenue lors de la dernière tentative, l'afficher.
        if (authProvider.error != null && !authProvider.isLoading) {
          // Utilise addPostFrameCallback pour afficher la SnackBar après le build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authProvider.error!),
                backgroundColor: Colors.red,
              ),
            );
            // Effacer l'erreur pour ne pas l'afficher à nouveau.
            authProvider.clearError();
          });
        }

        return const UnifiedLoginScreen();
      },
    );
  }
}
