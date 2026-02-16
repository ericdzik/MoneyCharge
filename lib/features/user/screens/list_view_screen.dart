import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/utils/responsive_helper.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';
import 'package:locacharge/core/widgets/merchant_card.dart';
import 'package:locacharge/features/user/models/merchant_model.dart';
import 'package:locacharge/providers/merchant_provider.dart';

class ListViewScreen extends StatefulWidget {
  final GoogleMapController? mapController;
  const ListViewScreen({super.key, this.mapController});

  @override
  State<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  String _sortOption = 'distance';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MerchantProvider>(context, listen: false).listenToMerchants();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Merchant> _sortMerchants(List<Merchant> merchants) {
    final sortedList = List<Merchant>.from(merchants);
    switch (_sortOption) {
      case 'name':
        sortedList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'rating':
      case 'distance':
      default:
        break;
    }
    return sortedList;
  }

  void _openDirections(Merchant merchant) {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${merchant.latitude},${merchant.longitude}&travelmode=driving',
    );
    launchUrl(uri, mode: LaunchMode.externalApplication).then((ok) {
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Impossible d'ouvrir l'itineraire."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Points de service",
        showLogo: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Consumer<MerchantProvider>(
        builder: (context, merchantProvider, child) {
          final merchants = _sortMerchants(merchantProvider.merchants);
          return ListView(
            controller: _scrollController,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: AppDimensions.paddingM,
                  bottom: AppDimensions.paddingM,
                ),
                child: _FilterChips(
                  selectedSort: _sortOption,
                  onSortChanged: (value) {
                    setState(() => _sortOption = value);
                  },
                ),
              ),
              if (merchants.isEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height - 300,
                  child: _EmptyState(),
                )
              else
                ...merchants.map((merchant) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.paddingM,
                    ),
                    child: MerchantCard(
                      merchant: merchant,
                      onTap: () {
                        if (widget.mapController != null) {
                          widget.mapController!.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              LatLng(merchant.latitude, merchant.longitude),
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
                      onDirectionsPressed: () => _openDirections(merchant),
                    ),
                  );
                }).toList(),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// MODERN UI WIDGETS
// ============================================================================

class _FilterChips extends StatelessWidget {
  final String selectedSort;
  final ValueChanged<String> onSortChanged;

  const _FilterChips({required this.selectedSort, required this.onSortChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                size: ResponsiveHelper.getIconSize(context, baseSize: 20),
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppDimensions.paddingS),
              Text(
                'Trier par',
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveHelper.getFontSize(context, baseSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Wrap(
            spacing: AppDimensions.paddingS,
            runSpacing: AppDimensions.paddingS,
            children: [
              _SortChip(
                label: 'Distance',
                value: 'distance',
                selected: selectedSort == 'distance',
                onTap: () => onSortChanged('distance'),
              ),
              _SortChip(
                label: 'Nom',
                value: 'name',
                selected: selectedSort == 'name',
                onTap: () => onSortChanged('name'),
              ),
              _SortChip(
                label: 'Note',
                value: 'rating',
                selected: selectedSort == 'rating',
                onTap: () => onSortChanged('rating'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: selected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveHelper.getFontSize(context, baseSize: 14),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.store_outlined,
              size: ResponsiveHelper.getIconSize(context, baseSize: 60),
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          Text(
            'Aucun point de service',
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: ResponsiveHelper.getFontSize(context, baseSize: 20),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'Deplacer la carte ou rafraichir pour voir les points disponibles.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<MerchantProvider>().listenToMerchants(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Actualiser'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingS,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
