import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/merchant_card.dart';
import '../../../providers/merchant_provider.dart';
import '../../../core/constants/app_colors.dart';
import 'merchant_detail_screen.dart';
import '../models/merchant_model.dart'; // Ajout de l'import pour Merchant
import 'map_view_screen.dart'; // Ajout de l'import pour MapViewScreen
// import '../../../services/location_service.dart'; // Retiré car plus utilisé directement
import '../../../core/constants/app_routes.dart'; // Ajout de l'import pour AppRoutes

class ListViewScreen extends StatefulWidget {
  final GoogleMapController? mapController;
  const ListViewScreen({Key? key, this.mapController}) : super(key: key);

  @override
  State<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MerchantProvider>(context, listen: false).listenToMerchants();
    });
    _searchController.addListener(() {
      Provider.of<MerchantProvider>(context, listen: false)
          .applyFilters(searchQuery: _searchController.text, searchQueryIsSet: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: 'Liste des services',
        backgroundColor: AppColors.primary,
        showLogo: false,
      ),
      body: Stack(
        children: [
          // Image de fond qui s'étend sous l'AppBar
          Positioned.fill(
            child: Image.asset('assets/splash/33.png', fit: BoxFit.cover),
          ),
          // Contenu principal avec padding pour l'AppBar
          SafeArea(
            child: Column(
              children: [
                _buildFilterBar(),
                Expanded(
                  child: Consumer<MerchantProvider>(
                    builder: (context, merchantProvider, child) {
                      if (merchantProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (merchantProvider.merchants.isEmpty) {
                        return const Center(
                          child: Text('Aucun point de service trouvé'),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () {
                          merchantProvider.refreshMerchants();
                          return Future.value();
                        },
                        child: ListView.builder(
                          itemCount: merchantProvider.merchants.length,
                          itemBuilder: (context, index) {
                            final merchant = merchantProvider.merchants[index];
                            return MerchantCard(
                              merchant: merchant,
                              onTap: () {
                                if (widget.mapController != null) {
                                  widget.mapController!.animateCamera(
                                    CameraUpdate.newLatLngZoom(
                                      LatLng(
                                        merchant.latitude,
                                        merchant.longitude,
                                      ),
                                      16.0,
                                    ),
                                  );
                                }
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.merchantDetail,
                                  arguments: {'merchant': merchant},
                                );
                              },
                              onDirectionsPressed: () {
                                _openDirections(merchant);
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDirections(Merchant merchant) {
    Navigator.pushNamed(
      context,
      AppRoutes.mapView,
      arguments: {'merchant': merchant},
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: AppColors.background.withOpacity(0.95),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher par nom ou adresse...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Consumer<MerchantProvider>(
              builder: (context, merchantProvider, child) {
                return Row(
                  children: [
                    _buildFilterChip(
                      label: 'Ouvert',
                      icon: Icons.access_time,
                      isSelected: merchantProvider.filterOpen,
                      onSelected: (_) => merchantProvider.toggleFilterOpen(),
                    ),
                    const SizedBox(width: 8.0),
                    _buildFilterMenu(
                      label: 'Services',
                      icon: Icons.room_service,
                      options: merchantProvider.uniqueServiceCategories,
                      selectedOptions: merchantProvider.activeServiceFilters,
                      onApply: (selected) {
                        merchantProvider.applyFilters(services: selected, servicesIsSet: true);
                      },
                    ),
                    const SizedBox(width: 8.0),
                    _buildFilterMenu(
                      label: 'Opérateurs',
                      icon: Icons.sim_card,
                      options: ['Orange', 'MTN', 'Moov'], // Ces listes pourraient être globales
                      selectedOptions: merchantProvider.activeOperatorFilters,
                      onApply: (selected) {
                        merchantProvider.applyFilters(operators: selected, operatorsIsSet: true);
                      },
                    ),
                     const SizedBox(width: 8.0),
                    _buildFilterMenu(
                      label: 'Transfert',
                      icon: Icons.send_to_mobile,
                      options: ['T-Money', 'Flooz', 'Western Union'],
                      selectedOptions: merchantProvider.activeMoneyTransferFilters,
                      onApply: (selected) {
                        merchantProvider.applyFilters(moneyTransferTypes: selected, moneyTransferTypesIsSet: true);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primary.withOpacity(0.8),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }

  Widget _buildFilterMenu({
    required String label,
    required IconData icon,
    required List<String> options,
    required List<String> selectedOptions,
    required Function(List<String>) onApply,
  }) {
    return PopupMenuButton<String>(
      child: Chip(
        avatar: Icon(icon, size: 18),
        label: Text(label + (selectedOptions.isNotEmpty ? ' (${selectedOptions.length})' : '')),
        backgroundColor: selectedOptions.isNotEmpty ? AppColors.primary.withOpacity(0.8) : null,
        labelStyle: TextStyle(color: selectedOptions.isNotEmpty ? Colors.white : Colors.black),
      ),
      onSelected: (value) {
        // Géré par le contenu du popup
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            value: 'menu',
            enabled: false,
            child: _FilterMenuContent(
              options: options,
              initialSelectedOptions: selectedOptions,
              onApply: onApply,
            ),
          ),
        ];
      },
    );
  }
}

class _FilterMenuContent extends StatefulWidget {
  final List<String> options;
  final List<String> initialSelectedOptions;
  final Function(List<String>) onApply;

  const _FilterMenuContent({
    required this.options,
    required this.initialSelectedOptions,
    required this.onApply,
  });

  @override
  __FilterMenuContentState createState() => __FilterMenuContentState();
}

class __FilterMenuContentState extends State<_FilterMenuContent> {
  late List<String> _selectedOptions;

  @override
  void initState() {
    super.initState();
    _selectedOptions = List.from(widget.initialSelectedOptions);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 200, // Limite la hauteur de la liste
            child: ListView(
              children: widget.options.map((option) {
                return CheckboxListTile(
                  title: Text(option),
                  value: _selectedOptions.contains(option),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedOptions.add(option);
                      } else {
                        _selectedOptions.remove(option);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedOptions.clear();
                  });
                },
                child: const Text('Effacer'),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onApply(_selectedOptions);
                  Navigator.pop(context);
                },
                child: const Text('Appliquer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
