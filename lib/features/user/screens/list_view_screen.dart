import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/merchant_card.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/background_image_widget.dart';
import '../../../core/widgets/profile_avatar_widget.dart';
import '../../../providers/merchant_provider.dart';
import '../../../providers/auth_provider.dart';
import '../models/merchant_model.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

class ListViewScreen extends StatefulWidget {
  final GoogleMapController? mapController;
  const ListViewScreen({super.key, this.mapController});

  @override
  State<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  String _sortOption = 'distance';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MerchantProvider>(context, listen: false).listenToMerchants();
    });
  }

  List<Merchant> _sortMerchants(List<Merchant> merchants) {
    final sortedList = List<Merchant>.from(merchants);

    switch (_sortOption) {
      case 'name':
        sortedList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'rating':
      // Tri par rating si disponible
        break;
      case 'distance':
      default:
      // Tri par distance si disponible
        break;
    }

    return sortedList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        showLogo: false,
        title: 'Points de service',
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
          // Image de fond
          const Positioned.fill(child: BackgroundImage()),

          // Contenu principal
          SafeArea(
            child: _buildMerchantList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantList() {
    return Consumer<MerchantProvider>(
      builder: (context, merchantProvider, child) {
        if (merchantProvider.isLoading && merchantProvider.merchants.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: AppDimensions.paddingM),
                Text(
                  'Chargement des points de service...',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        if (merchantProvider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: AppDimensions.paddingM),
                  Text(
                    'Erreur',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  Text(
                    merchantProvider.error!,
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  ElevatedButton.icon(
                    onPressed: () {
                      merchantProvider.refreshMerchants();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (merchantProvider.merchants.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  Text(
                    'Aucun point de service trouvé',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  Text(
                    'Essayez de modifier vos filtres ou de rechercher dans une autre zone',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final sortedMerchants = _sortMerchants(merchantProvider.merchants);

        return Column(
          children: [
            // Header avec statistiques et filtres
            _buildHeader(),

            // Liste des marchands
            Expanded(
              child: RefreshIndicator(
                onRefresh: () {
                  merchantProvider.refreshMerchants();
                  return Future.value();
                },
                color: AppColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    left: AppDimensions.paddingS,
                    right: AppDimensions.paddingS,
                    bottom: AppDimensions.paddingM,
                  ),
                  itemCount: sortedMerchants.length,
                  itemBuilder: (context, index) {
                    final merchant = sortedMerchants[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingS,
                      ),
                      child: MerchantCard(
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
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingS),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Statistiques
          Consumer<MerchantProvider>(
            builder: (context, provider, _) {
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.location_on,
                      label: 'Points trouvés',
                      value: '${provider.merchants.length}',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingS),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.storefront,
                      label: 'Marchands',
                      value: '${provider.merchants.length}',
                      color: Colors.green,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppDimensions.paddingM),

          // Barre de tri
          Row(
            children: [
              Icon(
                Icons.sort,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.paddingS),
              Text(
                'Trier par:',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingS),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSortChip('Distance', 'distance'),
                      const SizedBox(width: AppDimensions.paddingXS),
                      _buildSortChip('Nom', 'name'),
                      const SizedBox(width: AppDimensions.paddingXS),
                      _buildSortChip('Note', 'rating'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingS),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortOption == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortOption = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingXS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(isSelected ? 1.0 : 0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
        ),
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
}