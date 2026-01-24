import 'package:locacharge/features/auth/providers/auth_provider.dart';
import 'rbac_constants.dart';

/// The central brain for Role-Based Access Control logic.
/// This class defines what each role CAN do.
class RoleManager {
  // Define base permissions for the "Leaf" roles (roles that don't inherit from others in this map)
  // Note: We handle inheritance logic in `getPermissionsForRole`.
  static const Map<UserType, Set<AppPermission>> _roleDefinitions = {
    UserType.user: {
      AppPermission.viewHome,
      AppPermission.viewUserProfile,
      AppPermission.editUserProfile,
      AppPermission.viewMarketplace,
      AppPermission.viewFavorites,
    },
    UserType.admin: {
      AppPermission.accessAdminDashboard,
      AppPermission.manageUsers,
      AppPermission.approveMerchants,
      AppPermission.manageSystemAds,
      AppPermission.viewSystemAnalytics,
      // Admins might also need to see the home feed?
      AppPermission.viewHome,
    },
    // UserType.merchant is handled via inheritance below
    UserType.merchant: {
      AppPermission.accessMerchantDashboard,
      AppPermission.manageStock,
      AppPermission.createInvoice,
      AppPermission.viewSalesByType,
      AppPermission.manageBusinessProfile,
      AppPermission.respondToReviews,
    },
  };

  /// Returns the complete set of permissions for a given role,
  /// applying inheritance rules (e.g., Merchant extends User).
  Set<AppPermission> getPermissionsForRole(
    UserType role, {
    List<String>? backendOverrides,
  }) {
    final permissions = <AppPermission>{};

    // === INHERITANCE LOGIC ===

    // 1. Everyone gets User permissions?
    // Or strictly: Merchant extends User.
    if (role == UserType.merchant) {
      // Merchant inherits all User capabilities
      final userPerms = _roleDefinitions[UserType.user] ?? {};
      final merchantPerms = _roleDefinitions[UserType.merchant] ?? {};

      permissions.addAll(userPerms);
      permissions.addAll(merchantPerms);

      // Debug logs
      print('🔐 RoleManager: Building permissions for MERCHANT');
      print(
        '   📋 User permissions inherited: ${userPerms.map((p) => p.toString().split('.').last).join(', ')}',
      );
      print(
        '   📋 Merchant permissions added: ${merchantPerms.map((p) => p.toString().split('.').last).join(', ')}',
      );
      print('   ✅ Total permissions: ${permissions.length}');
    } else {
      // Standard roles
      permissions.addAll(_roleDefinitions[role] ?? {});
      print(
        '🔐 RoleManager: Building permissions for ${role.toString().toUpperCase()}',
      );
      print('   ✅ Total permissions: ${permissions.length}');
    }

    // === DYNAMIC OVERRIDES (Future Proofing) ===
    if (backendOverrides != null) {
      for (final permissionName in backendOverrides) {
        final permission = _parsePermission(permissionName);
        if (permission != null) {
          permissions.add(permission);
        }
      }
    }

    return permissions;
  }

  /// Helper to convert backend string "VIEW_HOME" -> AppPermission.viewHome
  AppPermission? _parsePermission(String name) {
    try {
      // Simple strategy: match enum name or a custom mapping
      return AppPermission.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
