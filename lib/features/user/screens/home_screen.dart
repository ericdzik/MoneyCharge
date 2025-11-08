import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/features/user/screens/favorites_screen.dart';
import 'package:locacharge/features/merchant/screens/merchant_profile_screen.dart';
import 'package:locacharge/features/user/widgets/ad_carousel_widget.dart';
import 'package:locacharge/features/user/widgets/filter_widget.dart';
import 'package:locacharge/features/user/widgets/search_bar_widget.dart';
import 'package:locacharge/providers/auth_provider.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../core/widgets/profile_avatar_widget.dart';
import '../../../core/widgets/merchant_counter_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/map_widget.dart';
import 'list_view_screen.dart';
import 'user_profile_screen.dart';
import '../../../providers/merchant_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/ad_provider.dart';

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
      MapViewContent(onMapCreated: (controller) => _mapController = controller),
      ListViewScreen(mapController: _mapController),
      const FavoritesScreen(),
      isMerchant
          ? const MerchantProfileScreen()
          : const UserProfileScreen(showBackground: true),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isMerchant = authProvider.userType == UserType.merchant;
    final screens = _buildScreens(isMerchant);

    return Scaffold(
      extendBodyBehindAppBar: _currentIndex == 0,
      body: _currentIndex == 0
          ? _buildMapView(screens[0])
          : SafeArea(child: screens[_currentIndex]),
      bottomNavigationBar: CustomBottomNavBar(
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.95),
                  AppColors.primary.withOpacity(0.85),
                  AppColors.primary.withOpacity(0.0),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingS,
                  AppDimensions.paddingS,
                  AppDimensions.paddingS,
                  AppDimensions.paddingL,
                ),
                child: Column(
                  children: [
                    // Header avec titre et avatar
                    Row(
                      children: [
                        Text(
                          'Géo Money&Charge',
                          style: AppTextStyles.body1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const Spacer(),
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) => ProfileAvatar(
                            imageUrl: auth.appUserProfile?.profileImageUrl,
                          ),
                        ),
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
        ),

        // Compteur de marchands flottant
        Positioned(
          bottom: AppDimensions.paddingM,
          left: AppDimensions.paddingS,
          right: AppDimensions.paddingS,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Carrousel publicitaire
              const AdCarouselWidget(),
              const SizedBox(height: AppDimensions.paddingS),

              // Compteur de marchands
              Consumer<MerchantProvider>(
                builder: (context, provider, _) {
                  if (provider.merchants.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: MerchantCounterCard(
                      merchantCount: provider.merchants.length,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ListViewScreen(),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
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
            color: AppColors.primary.withOpacity(0.1),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (provider.error != null) {
          return Container(
            color: AppColors.primary.withOpacity(0.1),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Text(
                      "Erreur: ${provider.error}",
                      style: AppTextStyles.body1.copyWith(color: AppColors.error),
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
            color: AppColors.primary.withOpacity(0.1),
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