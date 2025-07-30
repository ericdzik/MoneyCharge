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
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          final userType = authProvider.userType;
          String route = RouteGuards.getDefaultRouteForUserType(userType);

          // Using WidgetsBinding.instance.addPostFrameCallback to avoid errors
          // related to navigation during a build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, route);
          });

          // Return a placeholder while navigation is happening
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          return const UnifiedLoginScreen();
        }
      },
    );
  }
}
