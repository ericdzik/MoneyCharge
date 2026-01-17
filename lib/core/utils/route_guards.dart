import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';
import '../constants/app_routes.dart';

class RouteGuards {
  // Vérifier si l'utilisateur est authentifié
  static bool isAuthenticated(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAuthenticated;
  }

  // Vérifier si l'utilisateur est un marchand
  static bool isMerchant(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAuthenticated &&
        authProvider.userType == UserType.merchant;
  }

  // Vérifier si l'utilisateur est un admin
  static bool isAdmin(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAuthenticated &&
        authProvider.userType == UserType.admin;
  }

  // Vérifier si l'utilisateur est un utilisateur normal
  static bool isUser(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAuthenticated &&
        authProvider.userType == UserType.user;
  }

  // Rediriger selon le type d'utilisateur
  static String getDefaultRouteForUserType(UserType? userType) {
    switch (userType) {
      case UserType.merchant:
        return AppRoutes.merchantDashboard;
      case UserType.admin:
        return AppRoutes.adminDashboard;
      case UserType.user:
      default:
        return AppRoutes.home;
    }
  }

  // Vérifier les permissions pour une route
  static bool hasPermissionForRoute(BuildContext context, String route) {
    if (route.startsWith('/merchant/')) {
      return isMerchant(context);
    } else if (route.startsWith('/admin/')) {
      return isAdmin(context);
    } else if (route.startsWith('/user/')) {
      return isUser(context);
    }
    return true; // Routes publiques
  }

  // Middleware pour vérifier l'authentification
  static Widget requireAuth(Widget child, {String? redirectTo}) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(
              context,
              redirectTo ?? AppRoutes.login,
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return child;
      },
    );
  }

  // Middleware pour vérifier le type d'utilisateur
  static Widget requireUserType(
    Widget child,
    UserType requiredType, {
    String? redirectTo,
  }) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(
              context,
              redirectTo ?? AppRoutes.login,
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.userType != requiredType) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(
              context,
              redirectTo ?? getDefaultRouteForUserType(authProvider.userType),
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return child;
      },
    );
  }
}
