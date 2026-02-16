import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/constants/app_routes.dart';
import 'package:locacharge/core/widgets/adaptive_navigation.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';

// Screens
import 'package:locacharge/features/user/screens/home_feed_screen.dart';
import 'package:locacharge/features/user/screens/maps_screen.dart';
import 'package:locacharge/features/user/screens/list_view_screen.dart';
import 'package:locacharge/features/user/screens/favorites_screen.dart';
import 'package:locacharge/features/profile/unified_profile_screen.dart';
import 'package:locacharge/features/merchant/screens/merchant_dashboard_tab.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    // Determine user type and build pages only once if possible.
    // However, permissions might change, so we can rebuild if dependencies change.
    final authProvider = Provider.of<AuthProvider>(context);
    final isMerchant = authProvider.userType == UserType.merchant;

    // We construct the page list based on UserType
    final List<Widget> pages = _buildPages(isMerchant);
    final List<NavItem> navItems = _buildNavItems(context, isMerchant);

    // Ensure index is valid
    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: AdaptiveBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        customItems: navItems,
      ),
    );
  }

  List<Widget> _buildPages(bool isMerchant) {
    // Common pages
    final home = const HomeFeedScreen();
    // MapViewContent requires parameters usually, but typically wrapped in MapsScreen.
    // MapsScreen has its own Scaffold. We should probably use the Content widget content directly if available,
    // OR just use MapsScreen and accept nested Scaffold.
    // MapsScreen in your code is just a Scaffold wrapper around MapViewContent.
    // However, MapViewContent in your code (Step 20) is a StatefulWidget.
    // Let's use MapsScreen for now, but we must ensure it doesn't duplicate the bottom bar.
    final map = const MapsScreen();
    final favorites = const FavoritesScreen();
    final profile = const UnifiedProfileScreen();

    if (isMerchant) {
      return [
        home,
        map,
        const MerchantDashboardTab(), // The Dashboard Tab
        favorites,
        profile,
      ];
    } else {
      return [
        home,
        map,
        // List View is index 2 for User in AdaptiveNavigationConfig
        const ListViewScreen(),
        favorites,
        profile,
      ];
    }
  }

  List<NavItem> _buildNavItems(BuildContext context, bool isMerchant) {
    if (isMerchant) {
      // Merchant Navigation
      return [
        const NavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Accueil',
          route: AppRoutes.home,
        ),
        const NavItem(
          icon: Icons.map_outlined,
          activeIcon: Icons.map,
          label: 'Carte',
          route: AppRoutes.mapView,
        ),
        const NavItem(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          label: 'Bureau', // "Bureau" or "Espace Pro"
          route: AppRoutes.merchantDashboard,
        ),
        const NavItem(
          icon: Icons.favorite_outline,
          activeIcon: Icons.favorite,
          label: 'Favoris',
          route: AppRoutes.favorites,
        ),
        const NavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profil',
          route: AppRoutes.userProfile,
        ),
      ];
    } else {
      // Standard User Navigation
      return AdaptiveNavigationConfig.userNavItems;
    }
  }
}
