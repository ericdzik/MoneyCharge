import 'package:locacharge/core/constants/app_routes.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';
import 'rbac_constants.dart';

/// Configuration centralisée de la navigation basée sur les permissions
///
/// Cette classe définit quelles routes sont accessibles avec quelles permissions,
/// permettant une gestion centralisée et évolutive de l'accès aux écrans.
class NavigationConfig {
  /// Map des routes vers les permissions requises
  /// Si une route n'est pas dans cette map, elle est considérée comme publique (authentifiée)
  static const Map<String, AppPermission> routePermissions = {
    // === USER ROUTES ===
    AppRoutes.home: AppPermission.viewHome,
    AppRoutes.listView: AppPermission.viewMarketplace,
    AppRoutes.merchantDetail: AppPermission.viewMarketplace,
    AppRoutes.advertisementDetail: AppPermission.viewMarketplace,
    AppRoutes.userProfile: AppPermission.viewUserProfile,
    AppRoutes.favorites: AppPermission.viewFavorites,
    AppRoutes.editProfile: AppPermission.editUserProfile,

    // === MERCHANT ROUTES ===
    AppRoutes.merchantDashboard: AppPermission.accessMerchantDashboard,
    AppRoutes.merchantCard: AppPermission.manageBusinessProfile,
    AppRoutes.merchantReviews: AppPermission.respondToReviews,
    AppRoutes.editMerchantProfile: AppPermission.manageBusinessProfile,
    AppRoutes.merchantProfile: AppPermission.manageBusinessProfile,
    AppRoutes.stockManagement: AppPermission.manageStock,
    AppRoutes.salesScreen: AppPermission.viewSalesByType,
    AppRoutes.createInvoice: AppPermission.createInvoice,

    // === ADMIN ROUTES ===
    AppRoutes.adminDashboard: AppPermission.accessAdminDashboard,
    AppRoutes.adminPendingVerifications: AppPermission.approveMerchants,
    AppRoutes.adminAds: AppPermission.manageSystemAds,
    AppRoutes.adminAddAd: AppPermission.manageSystemAds,
  };

  /// Routes communes accessibles à tous les utilisateurs authentifiés
  static const List<String> commonRoutes = [
    AppRoutes.notifications,
    AppRoutes.promotions,
    AppRoutes.help,
    AppRoutes.privacy,
    AppRoutes.about,
  ];

  /// Vérifie si une route est publique (pas d'authentification requise)
  static bool isPublicRoute(String? routeName) {
    const publicRoutes = [
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.merchantRegister,
      AppRoutes.forgotPassword,
    ];
    return publicRoutes.contains(routeName);
  }

  /// Vérifie si une route est commune (accessible à tous les utilisateurs authentifiés)
  static bool isCommonRoute(String? routeName) {
    return commonRoutes.contains(routeName);
  }

  /// Récupère la permission requise pour une route donnée
  static AppPermission? getRequiredPermission(String? routeName) {
    if (routeName == null) return null;
    return routePermissions[routeName];
  }

  /// Détermine l'écran initial basé sur le type d'utilisateur
  static String getInitialRouteForUserType(UserType userType) {
    switch (userType) {
      case UserType.user:
        return AppRoutes.home;
      case UserType.merchant:
        return AppRoutes.merchantDashboard;
      case UserType.admin:
        return AppRoutes.adminDashboard;
      default:
        return AppRoutes.login;
    }
  }
}
