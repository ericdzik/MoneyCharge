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
import '../../../core/widgets/background_image_widget.dart';
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

  bool get _needsFullScreenLayout =>
      _currentIndex == 1 || _currentIndex == 2 || _currentIndex == 3;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isMerchant = authProvider.userType == UserType.merchant;
    final screens = _buildScreens(isMerchant);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: 'Géo Money&Charge',
        backgroundColor: AppColors.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.paddingS),
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) => ProfileAvatar(
                imageUrl: auth.appUserProfile?.profileImageUrl,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: BackgroundImage()),
          SafeArea(
            top: !_needsFullScreenLayout,
            child: Padding(
              padding: EdgeInsets.all(
                _needsFullScreenLayout ? 0 : AppDimensions.paddingS,
              ),
              child: Column(
                children: [
                  if (_currentIndex == 0) ...[
                    const SearchBarWidget(),
                    const FilterWidget(),
                  ],
                  Expanded(
                    child: _needsFullScreenLayout
                        ? screens[_currentIndex]
                        : Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusM,
                              ),
                            ),
                            child: screens[_currentIndex],
                          ),
                  ),
                  if (_currentIndex == 0) ...[
                    const SizedBox(height: AppDimensions.paddingS),
                    Consumer<MerchantProvider>(
                      builder: (context, provider, _) {
                        if (provider.merchants.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return MerchantCounterCard(
                          merchantCount: provider.merchants.length,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ListViewScreen(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    const AdCarouselWidget(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
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
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Text(
              "Erreur: ${provider.error}",
              style: AppTextStyles.body1.copyWith(color: AppColors.error),
            ),
          );
        }

        if (provider.merchants.isEmpty) {
          return Center(
            child: Text(
              "Aucun point de service trouvé.",
              style: AppTextStyles.body1,
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