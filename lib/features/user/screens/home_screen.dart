import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart'; // Assurer l'import
// import '../../../core/utils/color_utils.dart'; // Semble ne plus être utilisé directement ici
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
  // Les écrans sont définis ici, s'assurer que leurs constructeurs sont const si possible
  final List<Widget> _screens = [
    const MapViewContent(),
    const ListViewScreen(),
    const Center(child: Text('Favoris - TODO')), // Placeholder
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Les couleurs du BottomNavigationBar sont gérées par BottomNavigationBarThemeData dans AppTheme
    return Scaffold(
      appBar: const CustomAppBar( // CustomAppBar utilise AppColors.primary
        title: 'LocaCharge',
        actions: [
          CircleAvatar(
            backgroundColor: AppColors.onPrimary, // Fond blanc (sur AppBar verte)
            child: Icon(Icons.person, color: AppColors.primary), // Icône verte
          ),
          SizedBox(width: AppDimensions.paddingM), // Ajusté pour cohérence avec AppDimensions
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        // type, selectedItemColor, unselectedItemColor, etc. sont pris du thème
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
        final locationProvider = Provider.of<LocationProvider>(context, listen: false); // listen:false si pas besoin de rebuild ici pour ça

        List<Merchant> processedMerchants = merchantProvider.merchants.map((m) {
          // Le calcul de distance pourrait être fait ailleurs si ce widget ne doit pas en dépendre directement
          // ou si MerchantModel peut stocker cette info temporairement.
          // Pour l'instant, on le laisse pour illustrer.
          // double distanceInMeters = locationProvider.calculateDistanceFromCurrent(m.latitude, m.longitude);
          return m;
        }).toList();

        return Column(
          children: [
            const FilterBarWidget(), // S'assurer que ce widget est aussi themé
            Expanded(
              child: Stack(
                children: [
                  if (merchantProvider.isLoading && merchantProvider.merchants.isEmpty)
                    const Center(child: CircularProgressIndicator(color: AppColors.primary)) // Couleur du spinner
                  else if (merchantProvider.error != null)
                    Center(child: Text("Erreur: ${merchantProvider.error}", style: AppTextStyles.body1.copyWith(color: AppColors.error)))
                  else if (merchantProvider.merchants.isEmpty)
                    Center(child: Text("Aucun point de service trouvé.", style: AppTextStyles.body1))
                  else
                    MapWidget( // S'assurer que MapWidget est aussi themé
                      merchants: processedMerchants,
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
                      bottom: AppDimensions.paddingL, // Utiliser AppDimensions
                      left: AppDimensions.paddingM,
                      right: AppDimensions.paddingM,
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.surface, // Beige clair
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM), // Utiliser AppDimensions
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1), // Ombre plus subtile
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '${merchantProvider.merchants.length} points de service trouvés',
                                style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600), // Texte en noir doux
                              ),
                            ),
                            const SizedBox(width: AppDimensions.paddingM),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ListViewScreen(), // Assurer que ListViewScreen est themé
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary, // Orange
                                foregroundColor: AppColors.onSecondary, // Noir (défini dans AppColors)
                                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM, vertical: AppDimensions.paddingS),
                                textStyle: AppTextStyles.button.copyWith(fontSize: 12), // AppTextStyles.button est déjà blanc
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
