import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/core/security/permission_provider.dart';
import 'package:locacharge/core/security/rbac_constants.dart';

/// Widget de navigation intelligent qui s'adapte aux permissions de l'utilisateur
///
/// Ce widget permet de naviguer vers des écrans en vérifiant automatiquement
/// les permissions, sans avoir à dupliquer la logique de contrôle d'accès.
class RoleAwareNavigation {
  /// Navigate to a route with automatic permission checking
  static Future<T?> navigateTo<T>({
    required BuildContext context,
    required String routeName,
    AppPermission? requiredPermission,
    Object? arguments,
  }) async {
    final permissionProvider = Provider.of<PermissionProvider>(
      context,
      listen: false,
    );

    // Si une permission est requise, vérifier
    if (requiredPermission != null) {
      if (!permissionProvider.hasPermission(requiredPermission)) {
        _showAccessDeniedMessage(context);
        return null;
      }
    }

    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  /// Navigate and replace current route
  static Future<T?> navigateAndReplace<T>({
    required BuildContext context,
    required String routeName,
    AppPermission? requiredPermission,
    Object? arguments,
  }) async {
    final permissionProvider = Provider.of<PermissionProvider>(
      context,
      listen: false,
    );

    if (requiredPermission != null) {
      if (!permissionProvider.hasPermission(requiredPermission)) {
        _showAccessDeniedMessage(context);
        return null;
      }
    }

    return Navigator.pushReplacementNamed<T, void>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and remove all previous routes
  static Future<T?> navigateAndRemoveUntil<T>({
    required BuildContext context,
    required String routeName,
    AppPermission? requiredPermission,
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) async {
    final permissionProvider = Provider.of<PermissionProvider>(
      context,
      listen: false,
    );

    if (requiredPermission != null) {
      if (!permissionProvider.hasPermission(requiredPermission)) {
        _showAccessDeniedMessage(context);
        return null;
      }
    }

    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Check if user can access a specific feature
  static bool canAccess(BuildContext context, AppPermission permission) {
    final permissionProvider = Provider.of<PermissionProvider>(
      context,
      listen: false,
    );
    return permissionProvider.hasPermission(permission);
  }

  /// Show access denied message
  static void _showAccessDeniedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Accès refusé. Vous n'avez pas la permission nécessaire.",
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

/// Extension pour faciliter la navigation depuis n'importe quel BuildContext
extension NavigationExtension on BuildContext {
  /// Navigate with permission check
  Future<T?> navigateToWithPermission<T>({
    required String routeName,
    AppPermission? requiredPermission,
    Object? arguments,
  }) {
    return RoleAwareNavigation.navigateTo<T>(
      context: this,
      routeName: routeName,
      requiredPermission: requiredPermission,
      arguments: arguments,
    );
  }

  /// Check if user has permission
  bool hasPermission(AppPermission permission) {
    return RoleAwareNavigation.canAccess(this, permission);
  }
}
