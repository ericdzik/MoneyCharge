import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'permission_provider.dart';
import 'rbac_constants.dart';

/// A widget that conditionally builds its child based on permissions.
///
/// Usage:
/// ```dart
/// AccessControl(
///   permission: AppPermission.manageStock,
///   child: EditStockButton(),
///   fallback: SizedBox.shrink(), // Optional: what to show if denied
/// )
/// ```
class AccessControl extends StatelessWidget {
  final AppPermission permission;
  final Widget child;
  final Widget? fallback;

  const AccessControl({
    Key? key,
    required this.permission,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionProvider>(
      builder: (context, permissionProvider, _) {
        if (permissionProvider.hasPermission(permission)) {
          return child;
        }
        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}
