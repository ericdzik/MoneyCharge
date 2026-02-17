import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';
import 'package:locacharge/core/utils/logger.dart';
import 'rbac_constants.dart';
import 'role_manager.dart';

/// A Provider that exposes the current user's permissions.
/// It listens to [AuthProvider] and updates permissions automatically when the user/role changes.
class PermissionProvider with ChangeNotifier {
  AuthProvider _authProvider;
  final RoleManager _roleManager = RoleManager();

  Set<AppPermission> _currentPermissions = {};
  UserType? _lastUserType;
  bool? _lastAuthState;

  PermissionProvider(this._authProvider) {
    _calculatePermissions();
  }

  // Used by ProxyProvider to update when AuthProvider changes
  void update(AuthProvider authProvider) {
    _authProvider = authProvider;

    // Recalculer si le type d'utilisateur ou l'état d'authentification a changé
    if (authProvider.userType != _lastUserType ||
        authProvider.isAuthenticated != _lastAuthState) {
      _lastUserType = authProvider.userType;
      _lastAuthState = authProvider.isAuthenticated;
      _calculatePermissions();
    }
  }

  void _calculatePermissions() {
    if (!_authProvider.isAuthenticated) {
      _currentPermissions = {};
    } else {
      // Calculer les permissions basées sur le rôle
      _currentPermissions = _roleManager.getPermissionsForRole(
        _authProvider.userType,
      );

      // Debug: Afficher les permissions calculées (seulement en mode debug)
      AppLogger.security(
        'Calculated permissions for ${_authProvider.userType}: ${_currentPermissions.map((p) => p.toString().split('.').last).join(', ')}',
      );
    }
    notifyListeners();
  }

  /// The Core Check: Does the user have this specific permission?
  bool hasPermission(AppPermission permission) {
    final result = _currentPermissions.contains(permission);
    
    // Logs seulement en mode debug
    if (!result) {
      AppLogger.warning(
        'Permission denied: ${permission.toString().split('.').last} | User type: ${_authProvider.userType} | Available: ${_currentPermissions.map((p) => p.toString().split('.').last).join(', ')}',
      );
    }
    
    return result;
  }

  /// Check if user has ALL of the listed permissions
  bool hasAllPermissions(List<AppPermission> permissions) {
    return permissions.every((p) => _currentPermissions.contains(p));
  }

  /// Check if user has ANY of the listed permissions
  bool hasAnyPermission(List<AppPermission> permissions) {
    return permissions.any((p) => _currentPermissions.contains(p));
  }

  /// Get current permissions (for debugging)
  Set<AppPermission> get currentPermissions => _currentPermissions;
}
