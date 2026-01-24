import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/widgets/adaptive_navigation.dart';
// merchant profile replaced by unified profile screen
import 'package:locacharge/features/user/screens/favorites_screen.dart';
import 'package:locacharge/features/user/screens/list_view_screen.dart';
import 'package:locacharge/features/profile/unified_profile_screen.dart';
import 'package:locacharge/features/user/screens/home_feed_screen.dart';
import 'package:locacharge/features/user/widgets/filter_widget.dart';
import 'package:locacharge/features/user/widgets/map_widget.dart';
import 'package:locacharge/features/user/widgets/search_bar_widget.dart';
import 'package:locacharge/providers/ad_provider.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';
import 'package:locacharge/providers/location_provider.dart';
import 'package:locacharge/providers/merchant_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  GoogleMapController? _mapController;

  List<Widget> _buildScreens(bool isMerchant) {
    return [
      const HomeFeedScreen(), // New Accueil tab
      MapViewContent(onMapCreated: (controller) => _mapController = controller),
      ListViewScreen(mapController: _mapController),
      const FavoritesScreen(),
        const UnifiedProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isMerchant = authProvider.userType == UserType.merchant;
    final screens = _buildScreens(isMerchant);

    return Scaffold(
      drawer: const CustomDrawer(),
      extendBody: true, // Permet à la nav bar de flotter
      body:
          _currentIndex ==
              1 // Map is now at index 1
          ? _buildMapView(screens[1])
          : SafeArea(child: screens[_currentIndex]),
      bottomNavigationBar: AdaptiveBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildMapView(Widget mapContent) {
    return Stack(
      children: [
        // Carte en plein écran
        Positioned.fill(child: mapContent),

        // Barre de recherche et filtres flottants
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.95),
                  AppColors.primary.withValues(alpha: 0.85),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingS,
                AppDimensions.paddingS,
                AppDimensions.paddingS,
                AppDimensions.paddingL,
              ),
              child: Column(
                children: [
                  // Header avec titre et icone menu
                  Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingS),
                      Text(
                        'Géo Money&Charge',
                        style: AppTextStyles.body1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  const SearchBarWidget(),
                  const SizedBox(height: AppDimensions.paddingS),
                  const FilterWidget(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MapViewContent extends StatefulWidget {
  final Function(GoogleMapController)? onMapCreated;

  const MapViewContent({super.key, this.onMapCreated});

  @override
  State<MapViewContent> createState() => _MapViewContentState();
}

class _MapViewContentState extends State<MapViewContent> {
  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  void _initializeProviders() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MerchantProvider>().listenToMerchants();
      context.read<LocationProvider>().initialize();
      context.read<AdProvider>().fetchAds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.merchants.isEmpty) {
          return Container(
            color: AppColors.primary.withValues(alpha: 0.1),
            child: const LoadingIndicator(),
          );
        }

        if (provider.error != null) {
          return Container(
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Text(
                      "Erreur: ${provider.error}",
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        if (provider.merchants.isEmpty) {
          return Container(
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Text(
                      "Aucun point de service trouvé.",
                      style: AppTextStyles.body1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return MapWidget(
          merchants: provider.merchants,
          onMerchantSelected: (merchant) {
            Navigator.pushNamed(
              context,
              AppRoutes.merchantDetail,
              arguments: {'merchant': merchant},
            );
          },
          showUserLocation: true,
          initialZoom: 13.0,
          onMapCreated: widget.onMapCreated,
        );
      },
    );
  }
}
