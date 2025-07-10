import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';
// import '../../../core/utils/color_utils.dart'; // Retiré car non utilisé après suppression de blackWithAlpha
import '../widgets/map_widget.dart';
import '../widgets/filter_bar_widget.dart';
import '../models/merchant_model.dart';
import 'list_view_screen.dart';
import 'user_profile_screen.dart';
import '../../../providers/merchant_provider.dart';
import '../../../providers/location_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const MapViewContent(),
    const ListViewScreen(),
    const FavoritesScreen(), // Remplacer le placeholder par FavoritesScreen
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar( // Peut être const si les actions sont const
        title: 'Geo Money&Charge',
        actions: [
          Padding( // Ajout d'un Padding pour l'action de l'AppBar
            padding: const EdgeInsets.only(right: AppDimensions.paddingS), // Un peu d'espace à droite
            child: CircleAvatar(
              backgroundColor: AppColors.onPrimary, // Fond blanc (sur AppBar verte)
              child: Icon(Icons.person, color: AppColors.primary), // Icône verte
            ),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        // type, selectedItemColor, unselectedItemColor, selectedLabelStyle, unselectedLabelStyle
        // sont pris du BottomNavigationBarThemeData dans AppTheme.
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Carte'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Liste'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoris'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class MapViewContent extends StatefulWidget {
  const MapViewContent({super.key});

  @override
  State<MapViewContent> createState() => _MapViewContentState();
}

class _MapViewContentState extends State<MapViewContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<MerchantProvider>(context, listen: false).loadMerchants();
        Provider.of<LocationProvider>(context, listen: false).initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantProvider>(
      builder: (context, merchantProvider, child) {
        // final locationProvider = Provider.of<LocationProvider>(context, listen: false);
        // List<Merchant> processedMerchants = merchantProvider.merchants.map((m) {
        //   return m;
        // }).toList();
        // Pour l'instant, on passe directement merchantProvider.merchants

        return Column(
          children: [
            const FilterBarWidget(),
            Expanded(
              child: Stack(
                children: [
                  if (merchantProvider.isLoading && merchantProvider.merchants.isEmpty)
                    const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  else if (merchantProvider.error != null)
                    Center(child: Text("Erreur: ${merchantProvider.error}", style: AppTextStyles.body1.copyWith(color: AppColors.error)))
                  else if (merchantProvider.merchants.isEmpty)
                    Center(child: Text("Aucun point de service trouvé.", style: AppTextStyles.body1))
                  else
                    MapWidget(
                      merchants: merchantProvider.merchants, // Utiliser directement la liste du provider
                      onMerchantSelected: (merchant) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.merchantDetail,
                          arguments: {'merchant': merchant},
                        );
                      },
                      showUserLocation: true,
                      initialZoom: 13.0,
                    ),
                  if (!merchantProvider.isLoading && merchantProvider.error == null && merchantProvider.merchants.isNotEmpty)
                    Positioned(
                      bottom: AppDimensions.paddingL,
                      left: AppDimensions.paddingM,
                      right: AppDimensions.paddingM,
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.surface, // Beige clair
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '${merchantProvider.merchants.length} points de service trouvés',
                                style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.paddingM),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ListViewScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary, // Orange
                                foregroundColor: AppColors.onSecondary, // Noir
                                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM, vertical: AppDimensions.paddingS),
                                textStyle: AppTextStyles.button.copyWith(fontSize: 12, color: AppColors.onSecondary), // Assurer la couleur du texte
                              ),
                              child: const Text('Vue Liste'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
