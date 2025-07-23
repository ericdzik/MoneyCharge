import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/merchant_provider.dart';
import '../../../core/constants/app_text_styles.dart'; // Ajout pour AppTextStyles

class FilterBarWidget extends StatefulWidget {
  const FilterBarWidget({super.key});

  @override
  State<FilterBarWidget> createState() => _FilterBarWidgetState();
}

class _FilterBarWidgetState extends State<FilterBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  // Liste des services disponibles pour le dialogue de filtre
  List<String> _availableServices = [];
  final List<String> _stockStatusOptions = ['Disponible', 'Faible', 'Épuisé'];

  @override
  void initState() {
    super.initState();
    // Potentiellement initialiser _searchController.text si on veut qu'il reflète un filtre de recherche existant
    // final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);
    // _searchController.text = merchantProvider.searchQuery;
    // _searchController.addListener(_onSearchChanged); // Pour recherche dynamique
  }

  // void _onSearchChanged() {
  //   // Implémenter la logique de debounce ici si nécessaire
  //   final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);
  //   merchantProvider.applyFilters(searchQuery: _searchController.text, updateSearchQuery: true);
  // }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser Consumer pour reconstruire lorsque les filtres changent dans le provider
    return Consumer<MerchantProvider>(
      builder: (context, merchantProvider, child) {
        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize
                .min, // Pour que la Column ne prenne que la place nécessaire
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher (nom, adresse)...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  merchantProvider.applyFilters(
                                    searchQuery: '',
                                    searchQueryIsSet: true,
                                  );
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusS,
                          ),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingS,
                        ),
                      ),
                      onSubmitted: (query) {
                        merchantProvider.applyFilters(
                          searchQuery: query,
                          searchQueryIsSet: true,
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () =>
                        _showFilterDialog(context, merchantProvider),
                    tooltip: 'Plus de filtres',
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingS),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Si l'écran est trop petit, afficher les chips en colonne
                  if (constraints.maxWidth < 400) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMerchantTypeChip(
                          context,
                          merchantProvider,
                          'Tous',
                          null,
                        ),
                        const SizedBox(height: AppDimensions.paddingS),
                        Row(
                          children: [
                            _buildMerchantTypeChip(
                              context,
                              merchantProvider,
                              'Boutiques',
                              'boutique',
                            ),
                            const SizedBox(width: AppDimensions.paddingS),
                            _buildMerchantTypeChip(
                              context,
                              merchantProvider,
                              'Ambulants',
                              'ambulant',
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    // Disposition horizontale pour les écrans plus larges
                    return SingleChildScrollView(
                      // Pour les chips si trop nombreux
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildMerchantTypeChip(
                            context,
                            merchantProvider,
                            'Tous',
                            null,
                          ),
                          const SizedBox(width: AppDimensions.paddingS),
                          _buildMerchantTypeChip(
                            context,
                            merchantProvider,
                            'Boutiques',
                            'boutique',
                          ),
                          const SizedBox(width: AppDimensions.paddingS),
                          _buildMerchantTypeChip(
                            context,
                            merchantProvider,
                            'Ambulants',
                            'ambulant',
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMerchantTypeChip(
    BuildContext context,
    MerchantProvider provider,
    String label,
    String? filterValue,
  ) {
    final bool isSelected = provider.activeMerchantTypeFilter == filterValue;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        // Un ChoiceChip est sélectionné, on applique la valeur (ou null pour "Tous")
        // Les ChoiceChip ne se déselectionnent pas par un deuxième clic sur eux-mêmes s'ils font partie d'un groupe.
        // Le comportement est que seul un peut être actif.
        // Si l'utilisateur clique sur le même chip déjà sélectionné, onSelected est appelé avec selected = true.
        // On applique toujours la valeur du chip. Si c'est "Tous", filterValue est null.
        // Le ChoiceChip gère sa propre sélection visuelle.
        // On informe le provider que merchantType a été explicitement choisi.
        provider.applyFilters(
          merchantType: filterValue,
          merchantTypeIsSet: true,
        );
      },
      backgroundColor: isSelected
          ? AppColors.primary.withOpacity(0.1)
          : Colors.white,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: 1,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS / 2,
      ),
    );
  }

  void _showFilterDialog(
    BuildContext context,
    MerchantProvider merchantProvider,
  ) {
    // Use a Consumer here to get the latest list of available services
    final allServices = merchantProvider.merchants
        .expand((merchant) => merchant.services ?? [])
        .toSet()
        .toList();
    _availableServices = List<String>.from(allServices);

    // État local pour le dialogue, initialisé avec les filtres actifs du provider
    Map<String, bool> dialogSelectedServices = {};
    for (var service in _availableServices) {
      dialogSelectedServices[service] = merchantProvider.activeServiceFilters
          .contains(service);
    }

    String? dialogStockServiceFilter =
        merchantProvider.activeStockServiceFilter;
    // Si un service est actif pour le filtre de stock, et qu'il n'est pas dans la liste des services sélectionnés
    // pour le dialogue, on le désactive (car l'UI du dialogue ne le montrerait pas).
    if (dialogStockServiceFilter != null &&
        !(dialogSelectedServices[dialogStockServiceFilter] ?? false)) {
      dialogStockServiceFilter = null;
    }

    bool dialogOnlyShowAvailableStock =
        merchantProvider.onlyShowAvailableStockForService &&
        (dialogStockServiceFilter != null);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusM),
        ),
      ),
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            List<String> currentlyCheckedServicesInDialog =
                dialogSelectedServices.entries
                    .where((e) => e.value)
                    .map((e) => e.key)
                    .toList();
            bool showStockFilterOptionForDialog =
                currentlyCheckedServicesInDialog.length == 1;

            // Si l'option de stock doit être affichée et que dialogStockServiceFilter est null,
            // le pré-remplir avec le seul service coché.
            if (showStockFilterOptionForDialog &&
                dialogStockServiceFilter == null) {
              dialogStockServiceFilter = currentlyCheckedServicesInDialog.first;
            }
            // Si l'option de stock ne doit PAS être affichée, s'assurer que dialogStockServiceFilter est null
            // et que dialogOnlyShowAvailableStock est false.
            else if (!showStockFilterOptionForDialog) {
              dialogStockServiceFilter = null;
              dialogOnlyShowAvailableStock = false;
            }

            return Padding(
              // Ajout de Padding pour éviter que le clavier ne cache les boutons
              padding: MediaQuery.of(context).viewInsets,
              child: SingleChildScrollView(
                // Permettre le défilement si le contenu est trop long
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

                    Text(
                      'Services Proposés :',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ..._availableServices.map((serviceName) {
                      return CheckboxListTile(
                        title: Text(serviceName),
                        value: dialogSelectedServices[serviceName] ?? false,
                        onChanged: (bool? value) {
                          setDialogState(() {
                            dialogSelectedServices[serviceName] =
                                value ?? false;
                            // Réévaluer ici, car la logique est dans le builder du StatefulBuilder
                          });
                        },
                        activeColor: AppColors.primary,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),

                    const SizedBox(height: AppDimensions.paddingS),

                    if (showStockFilterOptionForDialog &&
                        dialogStockServiceFilter != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            title: Text(
                              'Uniquement stock disponible pour "$dialogStockServiceFilter"',
                            ),
                            value: dialogOnlyShowAvailableStock,
                            onChanged: (bool? value) {
                              setDialogState(() {
                                dialogOnlyShowAvailableStock = value ?? false;
                              });
                            },
                            activeColor: AppColors.primary,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: AppDimensions.paddingM),
                          Text(
                            'Filtrer par statut du stock :',
                            style: AppTextStyles.body1.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingM,
                                vertical: AppDimensions.paddingS,
                              ),
                            ),
                            value: merchantProvider.activeStockStatusFilter,
                            items: ['Tous', ..._stockStatusOptions].map((String status) {
                              return DropdownMenuItem<String>(
                                value: status == 'Tous' ? null : status,
                                child: Text(status),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              merchantProvider.applyFilters(
                                stockStatus: newValue,
                                stockStatusIsSet: true,
                              );
                            },
                          ),
                        ],
                      ),

                    const SizedBox(height: AppDimensions.paddingL),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool useColumnForButtons =
                            constraints.maxWidth <
                            300; // Threshold for switching to Column

                        if (useColumnForButtons) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  setDialogState(() {
                                    for (var key
                                        in dialogSelectedServices.keys) {
                                      dialogSelectedServices[key] = false;
                                    }
                                  });
                                  merchantProvider.applyFilters(
                                    clearServiceAndStockFilters: true,
                                  );
                                  Navigator.pop(dialogContext);
                                },
                                child: const Text('Réinitialiser'),
                              ),
                              const SizedBox(height: AppDimensions.paddingS),
                              ElevatedButton(
                                onPressed: () {
                                  List<String> finalSelectedServices =
                                      dialogSelectedServices.entries
                                          .where((e) => e.value)
                                          .map((e) => e.key)
                                          .toList();
                                  merchantProvider.applyFilters(
                                    services: finalSelectedServices,
                                    servicesIsSet: true,
                                    stockService: showStockFilterOptionForDialog
                                        ? dialogStockServiceFilter
                                        : null,
                                    stockServiceIsSet: true,
                                    onlyAvailableStock:
                                        showStockFilterOptionForDialog
                                        ? dialogOnlyShowAvailableStock
                                        : false,
                                    onlyAvailableStockIsSet: true,
                                  );
                                  Navigator.pop(dialogContext);
                                },
                                child: const Text('Appliquer'),
                              ),
                            ],
                          );
                        } else {
                          return Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setDialogState(() {
                                      for (var key
                                          in dialogSelectedServices.keys) {
                                        dialogSelectedServices[key] = false;
                                      }
                                    });
                                    merchantProvider.applyFilters(
                                      clearServiceAndStockFilters: true,
                                    );
                                    Navigator.pop(dialogContext);
                                  },
                                  child: const Text('Réinitialiser'),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingM),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    List<String> finalSelectedServices =
                                        dialogSelectedServices.entries
                                            .where((e) => e.value)
                                            .map((e) => e.key)
                                            .toList();
                                    merchantProvider.applyFilters(
                                      services: finalSelectedServices,
                                      servicesIsSet: true,
                                      stockService:
                                          showStockFilterOptionForDialog
                                          ? dialogStockServiceFilter
                                          : null,
                                      stockServiceIsSet: true,
                                      onlyAvailableStock:
                                          showStockFilterOptionForDialog
                                          ? dialogOnlyShowAvailableStock
                                          : false,
                                      onlyAvailableStockIsSet: true,
                                    );
                                    Navigator.pop(dialogContext);
                                  },
                                  child: const Text('Appliquer'),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
