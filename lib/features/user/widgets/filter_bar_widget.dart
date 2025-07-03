import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Ajout de Provider
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/merchant_provider.dart'; // Ajout de MerchantProvider

class FilterBarWidget extends StatefulWidget {
  const FilterBarWidget({super.key});

  @override
  State<FilterBarWidget> createState() => _FilterBarWidgetState();
}

class _FilterBarWidgetState extends State<FilterBarWidget> {
  // String _selectedFilter = 'Tous'; // Supprimé, l'état sera dans MerchantProvider
  // final List<String> _filters = [ // Supprimé
  //   'Tous',
  //   'Disponible',
  //   'Stock faible',
  //   'À proximité',
  // ];
  final TextEditingController _searchController = TextEditingController(); // Pour la recherche future

  @override
  Widget build(BuildContext context) {
    // Accéder au MerchantProvider pour l'état actuel des filtres et pour appliquer les nouveaux filtres
    final merchantProvider = Provider.of<MerchantProvider>(context);
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un point de service...',
                    prefixIcon: const Icon(Icons.search),
                    // La recherche sera implémentée plus tard
                    // suffixIcon: _searchController.text.isNotEmpty
                    //   ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                    //       _searchController.clear();
                    //       // merchantProvider.applyFilters(searchQuery: ''); // Exemple
                    //     })
                    //   : null,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                      vertical: AppDimensions.paddingS,
                    ),
                  ),
                  // onChanged: (query) {
                  //   // Déclencher la recherche (avec debounce)
                  //   // merchantProvider.applyFilters(searchQuery: query); // Exemple
                  // },
                ),
              ),
              IconButton( // Bouton pour les filtres avancés (services, stock)
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterDialog(context),
                tooltip: 'Filtres avancés',
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingS),
          // Filtres par Type de Marchand
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMerchantTypeChip(context, merchantProvider, 'Tous', null),
              _buildMerchantTypeChip(context, merchantProvider, 'Boutiques', 'boutique'),
              _buildMerchantTypeChip(context, merchantProvider, 'Ambulants', 'ambulant'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMerchantTypeChip(
    BuildContext context,
    MerchantProvider provider,
    String label,
    String? filterValue,
  ) {
    // La sélection est basée sur activeMerchantTypeFilter du provider
    final bool isSelected = provider.activeMerchantTypeFilter == filterValue;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) { // Un ChoiceChip ne peut être que sélectionné, pas dé-sélectionné directement par onSelected(false)
          provider.applyFilters(merchantType: filterValue);
        }
      },
      backgroundColor: AppColors.background,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingS, vertical: AppDimensions.paddingXS/2),
    );
  }

  void _showFilterDialog(BuildContext context) {
    // Utiliser le provider pour obtenir l'état actuel des filtres de service/stock
    // et pour initialiser l'état local du dialogue.
    final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);

    // État local pour le dialogue
    Map<String, bool> dialogSelectedServices = Map.from(
        merchantProvider.activeServiceFilters.asMap().map((_, s) => MapEntry(s, true))
    );
    // S'assurer que tous les services disponibles sont dans la map, même s'ils ne sont pas actifs
    final availableServices = ['Recharge crédit', 'Transfert d\'argent', 'Achat de carte SIM'];
    for (var service in availableServices) {
      dialogSelectedServices.putIfAbsent(service, () => false);
    }

    String? dialogStockServiceFilter = merchantProvider.activeStockServiceFilter;
    bool dialogOnlyShowAvailableStock = merchantProvider.onlyShowAvailableStockForService;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important pour les contenus longs
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext dialogContext) { // Utiliser un nouveau contexte pour le StatefulBuilder
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            // Logique pour déterminer si le checkbox de stock doit être affiché
            List<String> currentlyCheckedServices = dialogSelectedServices.entries
                .where((e) => e.value)
                .map((e) => e.key)
                .toList();
            bool showStockFilterOption = currentlyCheckedServices.length == 1;
            if (showStockFilterOption && dialogStockServiceFilter == null) {
                 // Si une seule case est cochée, on présélectionne ce service pour le filtre de stock
                dialogStockServiceFilter = currentlyCheckedServices.first;
            } else if (!showStockFilterOption) {
                // Si plus d'une ou zéro case est cochée, on ne peut pas filtrer par stock pour un service unique
                dialogStockServiceFilter = null;
                // dialogOnlyShowAvailableStock = false; // Optionnel: réinitialiser aussi ce booléen
            }


            return Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtrer par Services et Disponibilité',
                    style: AppTextStyles.h3.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),

                  Text('Services Proposés :', style: AppTextStyles.body1Bold),
                  ...availableServices.map((serviceName) {
                    return CheckboxListTile(
                      title: Text(serviceName),
                      value: dialogSelectedServices[serviceName] ?? false,
                      onChanged: (bool? value) {
                        setDialogState(() {
                          dialogSelectedServices[serviceName] = value ?? false;
                          // Réévaluer si le filtre de stock doit être affiché/modifié
                           List<String> updatedCheckedServices = dialogSelectedServices.entries
                              .where((e) => e.value)
                              .map((e) => e.key)
                              .toList();
                          if (updatedCheckedServices.length == 1) {
                            dialogStockServiceFilter = updatedCheckedServices.first;
                          } else {
                            dialogStockServiceFilter = null;
                            dialogOnlyShowAvailableStock = false; // Réinitialiser si plus d'un service ou aucun
                          }
                        });
                      },
                      activeColor: AppColors.primary,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),

                  const SizedBox(height: AppDimensions.paddingS),

                  if (showStockFilterOption && dialogStockServiceFilter != null)
                    CheckboxListTile(
                      title: Text('Uniquement stock disponible pour "$dialogStockServiceFilter"'),
                      value: dialogOnlyShowAvailableStock,
                      onChanged: (bool? value) {
                        setDialogState(() {
                          dialogOnlyShowAvailableStock = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),

                  const SizedBox(height: AppDimensions.paddingL),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Réinitialiser l'état local du dialogue et appliquer des filtres vides pour ces types
                            setDialogState(() {
                              for (var key in dialogSelectedServices.keys) {
                                dialogSelectedServices[key] = false;
                              }
                              dialogStockServiceFilter = null;
                              dialogOnlyShowAvailableStock = false;
                            });
                            merchantProvider.applyFilters(
                              services: [], // Efface les filtres de service
                              stockService: null, // Efface le filtre de stock
                              onlyAvailableStock: false,
                              // Ne pas mettre clearAll:true pour ne pas affecter le type de marchand
                            );
                            Navigator.pop(dialogContext); // Utiliser dialogContext
                          },
                          child: const Text('Réinitialiser Filtres'),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            List<String> finalSelectedServices = dialogSelectedServices.entries
                                .where((e) => e.value)
                                .map((e) => e.key)
                                .toList();

                            merchantProvider.applyFilters(
                              services: finalSelectedServices,
                              stockService: showStockFilterOption ? dialogStockServiceFilter : null,
                              onlyAvailableStock: showStockFilterOption ? dialogOnlyShowAvailableStock : false,
                              // Ne pas mettre clearAll:true pour ne pas affecter le type de marchand
                            );
                            Navigator.pop(dialogContext); // Utiliser dialogContext
                          },
                          child: const Text('Appliquer'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingS), // Pour l'espace en bas du BottomSheet
                ],
              ),
            );
          },
        );
      },
    );
  }
}
