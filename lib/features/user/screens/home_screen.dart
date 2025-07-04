import 'package:flutter/material.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart'; // Import AppRoutes
import '../../../core/utils/color_utils.dart';
import '../widgets/map_widget.dart';
import '../widgets/filter_bar_widget.dart';
import '../models/merchant_model.dart';
import 'list_view_screen.dart';
import 'user_profile_screen.dart'; // Import UserProfileScreen
import 'package:provider/provider.dart'; // Importer Provider
import '../../../providers/merchant_provider.dart'; // Importer MerchantProvider
import '../../../providers/location_provider.dart'; // Importer LocationProvider pour les calculs

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const MapViewContent(),    // Index 0
    const ListViewScreen(),    // Index 1
    const Center(child: Text('Favoris - TODO')), // Index 2 - Placeholder for Favorites
    const UserProfileScreen(), // Index 3 - Actual UserProfileScreen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'LocaCharge',
        actions: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
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
// Les imports ont été déplacés en haut du fichier.
}

class _MapViewContentState extends State<MapViewContent> {
  // List<Merchant> _merchants = []; // Supprimé, géré par MerchantProvider

  @override
  void initState() {
    super.initState();
    // Charger les marchands via le provider au démarrage de ce widget
    // Utiliser addPostFrameCallback pour s'assurer que le contexte est disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Vérifier si le widget est toujours monté
        Provider.of<MerchantProvider>(context, listen: false).loadMerchants();
        // Initialiser aussi LocationProvider si ce n'est pas déjà fait globalement
        Provider.of<LocationProvider>(context, listen: false).initialize();
      }
    });
  }

  // Future<void> _loadMerchants() async { ... } // Supprimé

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantProvider>(
      builder: (context, merchantProvider, child) {
        // Écouter aussi LocationProvider pour les mises à jour de position de l'utilisateur
        // qui pourraient affecter les distances.
        final locationProvider = Provider.of<LocationProvider>(context);

        List<Merchant> processedMerchants = merchantProvider.merchants.map((m) {
          double distanceInMeters = locationProvider.calculateDistanceFromCurrent(m.latitude, m.longitude);
          // Ici, on pourrait créer une nouvelle instance de Merchant ou un DTO avec les infos calculées
          // Pour l'instant, on ne modifie pas l'objet Merchant directement car ses champs ne sont pas finaux
          // Idéalement, Merchant aurait des champs non-finaux ou une méthode copyWith pour ces données dynamiques.
          // Pour cette étape, on passe les marchands tels quels et MapWidget devra gérer ces calculs
          // ou on suppose que le modèle Merchant est adapté pour stocker temporairement ces valeurs.
          // Pour simplifier, nous allons juste passer la liste et supposer que MapWidget peut utiliser LocationProvider.
          return m;
        }).toList();

        return Column(
          children: [
            const FilterBarWidget(),
            Expanded(
              child: Stack(
                children: [
                  if (merchantProvider.isLoading && merchantProvider.merchants.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (merchantProvider.error != null)
                    Center(child: Text("Erreur: ${merchantProvider.error}"))
                  else if (merchantProvider.merchants.isEmpty)
                    const Center(child: Text("Aucun point de service trouvé."))
                  else
                    MapWidget(
                      merchants: processedMerchants, // Utiliser la liste du provider
                      onMerchantSelected: (merchant) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.merchantDetail, // Use the correct route constant
                          arguments: {'merchant': merchant},
                        );
                      },
                      showUserLocation: true,
                      initialZoom: 13.0,
                    ),
                  if (!merchantProvider.isLoading && merchantProvider.error == null)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: ColorUtils.blackWithAlpha(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible( // Allow text to take available space and wrap if needed
                              child: Text(
                                '${merchantProvider.merchants.length} points de service trouvés',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.paddingM), // Add some spacing
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
                                backgroundColor: AppColors.secondary,
                                foregroundColor: const Color(0xFF92400E),
                                minimumSize: const Size(80, 32),
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
// Le code dupliqué et erroné qui se trouvait ici a été supprimé.
