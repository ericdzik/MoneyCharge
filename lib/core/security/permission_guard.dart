import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/core/constants/app_routes.dart';
import 'permission_provider.dart';
import 'rbac_constants.dart';

class PermissionGuard {
  static Widget check({
    required BuildContext context,
    required AppPermission permission,
    required Widget child,
    String redirectTo = AppRoutes.login,
  }) {
    // verifying permission synchronously might be tricky if provider isn't ready,
    // but usually Auth is ready by the time routes generate.
    final provider = Provider.of<PermissionProvider>(context, listen: false);

    if (provider.hasPermission(permission)) {
      return child;
    }

    // Redirect logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(redirectTo);

      // Optional: Show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Accès refusé. Vous n'avez pas la permission nécessaire.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    });

    // Return something generic while redirecting
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
