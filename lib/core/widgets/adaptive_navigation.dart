import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/core/constants/app_colors.dart';
import 'package:locacharge/core/constants/app_routes.dart';
import 'package:locacharge/core/security/permission_provider.dart';
import 'package:locacharge/core/security/rbac_constants.dart';

/// Item de navigation avec permission associée
class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final AppPermission? requiredPermission;
  final int? index; // Pour les tabs internes

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    this.requiredPermission,
    this.index,
  });
}

/// Configuration de navigation adaptative basée sur les rôles
class AdaptiveNavigationConfig {
  /// Navigation items pour les utilisateurs standards
  static const List<NavItem> userNavItems = [
    NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Accueil',
      route: AppRoutes.home,
      requiredPermission: AppPermission.viewHome,
      index: 0,
    ),
    NavItem(
      icon: Icons.map_outlined,
      activeIcon: Icons.map,
      label: 'Carte',
      route: AppRoutes.home, // Map view is in home screen
      requiredPermission: AppPermission.viewMarketplace,
      index: 1,
    ),
    NavItem(
      icon: Icons.list_alt_outlined,
      activeIcon: Icons.list_alt,
      label: 'Liste',
      route: AppRoutes.listView,
      requiredPermission: AppPermission.viewMarketplace,
      index: 2,
    ),
    NavItem(
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
      label: 'Favoris',
      route: AppRoutes.favorites,
      requiredPermission: AppPermission.viewFavorites,
      index: 3,
    ),
    NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profil',
      route: AppRoutes.userProfile,
      requiredPermission: AppPermission.viewUserProfile,
      index: 4,
    ),
  ];

  /// Navigation items spécifiques aux marchands (en plus des items User)
  static const List<NavItem> merchantSpecificNavItems = [
    NavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      route: AppRoutes.merchantDashboard,
      requiredPermission: AppPermission.accessMerchantDashboard,
    ),
    NavItem(
      icon: Icons.credit_card_outlined,
      activeIcon: Icons.credit_card,
      label: 'Carte',
      route: AppRoutes.home,
      requiredPermission: AppPermission.manageBusinessProfile,
    ),
    NavItem(
      icon: Icons.point_of_sale_outlined,
      activeIcon: Icons.point_of_sale,
      label: 'Ventes',
      route: AppRoutes.salesScreen,
      requiredPermission: AppPermission.viewSalesByType,
    ),
    NavItem(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      label: 'Stock',
      route: AppRoutes.stockManagement,
      requiredPermission: AppPermission.manageStock,
    ),
    NavItem(
      icon: Icons.store_outlined,
      activeIcon: Icons.store,
      label: 'Mon Commerce',
      route: AppRoutes.merchantProfile,
      requiredPermission: AppPermission.manageBusinessProfile,
    ),
  ];

  /// Récupère les items de navigation disponibles pour l'utilisateur actuel
  static List<NavItem> getAvailableNavItems(BuildContext context) {
    final permissionProvider = Provider.of<PermissionProvider>(
      context,
      listen: false,
    );

    final List<NavItem> availableItems = [];

    // Vérifier les items User
    for (final item in userNavItems) {
      if (item.requiredPermission == null ||
          permissionProvider.hasPermission(item.requiredPermission!)) {
        availableItems.add(item);
      }
    }

    // Vérifier les items Merchant
    for (final item in merchantSpecificNavItems) {
      if (item.requiredPermission == null ||
          permissionProvider.hasPermission(item.requiredPermission!)) {
        availableItems.add(item);
      }
    }

    return availableItems;
  }

  /// Récupère uniquement les items de navigation principaux (pour bottom nav)
  static List<NavItem> getMainNavItems(BuildContext context) {
    final permissionProvider = Provider.of<PermissionProvider>(
      context,
      listen: false,
    );

    // Si l'utilisateur a accès au dashboard marchand, montrer la nav marchand
    if (permissionProvider.hasPermission(
      AppPermission.accessMerchantDashboard,
    )) {
      return _getMerchantMainNavItems(permissionProvider);
    }

    // Sinon, montrer la nav utilisateur standard
    return _getUserMainNavItems(permissionProvider);
  }

  static List<NavItem> _getUserMainNavItems(PermissionProvider provider) {
    return userNavItems.where((item) {
      return item.requiredPermission == null ||
          provider.hasPermission(item.requiredPermission!);
    }).toList();
  }

  static List<NavItem> _getMerchantMainNavItems(PermissionProvider provider) {
    // Pour les marchands, on retourne les items User (car ils héritent)
    // Cela permet aux marchands d'accéder aux fonctionnalités User
    return userNavItems.where((item) {
      return item.requiredPermission == null ||
          provider.hasPermission(item.requiredPermission!);
    }).toList();
  }
}

/// Widget de barre de navigation adaptative
class AdaptiveBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem>? customItems;

  const AdaptiveBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.customItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items =
        customItems ?? AdaptiveNavigationConfig.getMainNavItems(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              items.length,
              (index) => _buildNavItem(
                item: items[index],
                isActive: currentIndex == index,
                onTap: () => onTap(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required NavItem item,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                color: isActive ? AppColors.primary : Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive ? AppColors.primary : Colors.grey.shade600,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
