import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/color_utils.dart';
import '../widgets/map_widget.dart';
import '../widgets/filter_bar_widget.dart';
import '../models/merchant_model.dart';
import 'list_view_screen.dart';

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
    const Center(child: Text('Favoris')),
    const Center(child: Text('Profil')),
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
}

class _MapViewContentState extends State<MapViewContent> {
  List<Merchant> _merchants = [];

  @override
  void initState() {
    super.initState();
    _loadMerchants();
  }

  Future<void> _loadMerchants() async {
    // Données de test pour l'écran d'accueil
    final merchants = [
      Merchant(
        id: '1',
        name: 'Station Total Lomé',
        address: 'Avenue de la Paix, Lomé',
        phone: '+228 22 21 21 21',
        hours: '24h/24',
        isOpen: true,
        status: MerchantStatus.available,
        latitude: 6.1319,
        longitude: 1.2228,
        distance: 0.5,
        walkingTime: '6 min',
        drivingTime: '2 min',
        services: ['Recharge', 'Paiement', 'Transfert'],
      ),
      Merchant(
        id: '2',
        name: 'Boutique Mobile Money',
        address: 'Rue du Commerce, Lomé',
        phone: '+228 22 22 22 22',
        hours: '7h-22h',
        isOpen: true,
        status: MerchantStatus.lowStock,
        latitude: 6.1350,
        longitude: 1.2250,
        distance: 1.2,
        walkingTime: '15 min',
        drivingTime: '4 min',
        services: ['Recharge', 'Paiement'],
      ),
    ];

    setState(() {
      _merchants = merchants;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const FilterBarWidget(),
        Expanded(
          child: Stack(
            children: [
              MapWidget(
                merchants: _merchants,
                onMerchantSelected: (merchant) {
                  // Navigation vers les détails du marchand
                  Navigator.pushNamed(
                    context,
                    '/merchant-details',
                    arguments: merchant,
                  );
                },
                showUserLocation: true,
                initialZoom: 13.0,
              ),
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
                      Text(
                        '${_merchants.length} points de service trouvés',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
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
  }
}
