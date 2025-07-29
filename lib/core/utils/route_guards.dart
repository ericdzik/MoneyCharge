import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../constants/app_routes.dart';

class RouteGuards {
  static bool _isAuthenticated(BuildContext context) {
    return Provider.of<AuthProvider>(context, listen: false).isAuthenticated;
  }

  static UserType _getUserType(BuildContext context) {
    return Provider.of<AuthProvider>(context, listen: false).userType;
  }

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

  static Widget requireUserType(Widget child, UserType requiredType) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated) {
          return _Redirect(
            routeName: AppRoutes.login,
          );
        }

        if (authProvider.userType != requiredType) {
          return _Redirect(
            routeName: getDefaultRouteForUserType(authProvider.userType),
          );
        }

        return child;
      },
    );
  }
}

class _Redirect extends StatefulWidget {
  final String routeName;

  const _Redirect({Key? key, required this.routeName}) : super(key: key);

  @override
  State<_Redirect> createState() => _RedirectState();
}

class _RedirectState extends State<_Redirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(widget.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
