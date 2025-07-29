import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/merchant_model.dart';
import '../../../services/location_service.dart';
import 'package:provider/provider.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:locacharge/features/user/screens/add_review_screen.dart';
import 'package:locacharge/features/user/widgets/review_list_widget.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/favorite_merchant_provider.dart'; // Ajout de FavoriteMerchantProvider

class MerchantDetailScreen extends StatefulWidget {
  final Merchant merchant;

  const MerchantDetailScreen({Key? key, required this.merchant})
    : super(key: key);

  @override
  _MerchantDetailScreenState createState() => _MerchantDetailScreenState();
}

class _MerchantDetailScreenState extends State<MerchantDetailScreen> {
  String _walkingTime = 'Calcul...';
  String _drivingTime = 'Calcul...';
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _calculateTravelTimes();
  }

  Future<void> _calculateTravelTimes() async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );

    if (locationProvider.currentPosition == null) {
      await locationProvider.initialize();
    }

    if (!mounted) return;

    if (locationProvider.currentPosition != null) {
      final distance = _locationService.calculateDistance(
        locationProvider.currentPosition!.latitude,
        locationProvider.currentPosition!.longitude,
        widget.merchant.latitude,
        widget.merchant.longitude,
      );

      if (mounted) {
        setState(() {
          _walkingTime = _locationService.calculateWalkingTime(distance);
          _drivingTime = _locationService.calculateDrivingTime(distance);
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _walkingTime = 'Position ?';
          _drivingTime = 'Position ?';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: widget.merchant.name,
        showLogo: false,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<FavoriteMerchantProvider>(
            // Utilisation de Consumer
            builder: (context, favoriteProvider, child) {
              final isFavorite = favoriteProvider.isFavorite(
                widget.merchant.id,
              );
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? AppColors.error
                      : null, // Couleur rouge si favori
                ),
                onPressed: () {
                  if (isFavorite) {
                    favoriteProvider.removeFavorite(widget.merchant.id);
                  } else {
                    favoriteProvider.addFavorite(widget.merchant.id);
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Partager
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Image de fond qui s'étend sous l'AppBar
          Positioned.fill(
            child: Image.asset('assets/splash/33.png', fit: BoxFit.cover),
          ),
          // Contenu principal avec padding pour l'AppBar
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          double headerHeight = constraints.maxWidth * 0.5;
                          if (headerHeight < 150) headerHeight = 50;
                          if (headerHeight > 300) headerHeight = 300;

                          return Container(
                            width: double.infinity,
                            height: headerHeight,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(190, 255, 255, 255),
                            ),
                            child: Stack(
                              children: [
                                if (widget.merchant.imageUrls != null &&
                                    widget.merchant.imageUrls!.isNotEmpty)
                                  Swiper(
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                          return Image.network(
                                            widget.merchant.imageUrls![index],
                                            fit: BoxFit.cover,
                                          );
                                        },
                                    itemCount:
                                        widget.merchant.imageUrls!.length,
                                    pagination: const SwiperPagination(),
                                    control: const SwiperControl(),
                                  )
                                else
                                  const Center(
                                    child: Icon(
                                      Icons.store,
                                      size: 40,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                Positioned(
                                  top: AppDimensions.paddingM,
                                  right: AppDimensions.paddingM,
                                  child: StatusBadge(status: _getStatusType()),
                                ),
                              ],
                            ),
                          );
                        },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusL,
                      ),
                    ),
                    margin: const EdgeInsets.all(AppDimensions.paddingM),
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(
                          icon: Icons.storefront,
                          title: 'Nom du commerce',
                          content: widget.merchant.name,
                        ),
                        _buildInfoCard(
                          icon: Icons.location_on,
                          title: 'Adresse',
                          content: widget.merchant.address,
                        ),
                        _buildInfoCard(
                          icon: Icons.phone,
                          title: 'Téléphone',
                          content: widget.merchant.phone,
                        ),
                        _buildInfoCard(
                          icon: Icons.access_time,
                          title: 'Horaires',
                          content:
                              '${_formatHours(widget.merchant.hours)}\n${widget.merchant.isOpen ? "🟢 Ouvert maintenant" : "🔴 Fermé"}',
                        ),
                        const SizedBox(height: AppDimensions.paddingM),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // Disposition horizontale pour tous les écrans
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildTimeCard(
                                    Icons.directions_walk,
                                    'À pied',
                                    _walkingTime,
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.paddingS),
                                Expanded(
                                  child: _buildTimeCard(
                                    Icons.directions_car,
                                    'En voiture',
                                    _drivingTime,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: AppDimensions.paddingL),
                        Text('Services disponibles', style: AppTextStyles.h3),
                        const SizedBox(height: AppDimensions.paddingM),
                        widget.merchant.services.isEmpty
                            ? const Text('Aucun service disponible.')
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  // Si l'écran est trop petit, afficher les services en colonne
                                  if (constraints.maxWidth < 350) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: widget.merchant.services.map((
                                        service,
                                      ) {
                                        return Container(
                                          key: ValueKey(service),
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(
                                            bottom: AppDimensions.paddingS,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppDimensions.paddingM,
                                            vertical: AppDimensions.paddingS,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius: BorderRadius.circular(
                                              AppDimensions.radiusS,
                                            ),
                                            border: Border.all(
                                              color: AppColors.border,
                                            ),
                                          ),
                                          child: Text(
                                            service,
                                            style: AppTextStyles.body2,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  } else {
                                    // Disposition Wrap pour les écrans plus larges
                                    return Wrap(
                                      spacing: AppDimensions.paddingS,
                                      runSpacing: AppDimensions.paddingS,
                                      children: widget.merchant.services.map((
                                        service,
                                      ) {
                                        return ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                constraints.maxWidth * 0.45,
                                          ),
                                          child: Container(
                                            key: ValueKey(service),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  AppDimensions.paddingM,
                                              vertical: AppDimensions.paddingS,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppDimensions.radiusS,
                                                  ),
                                              border: Border.all(
                                                color: AppColors.border,
                                              ),
                                            ),
                                            child: Text(
                                              service,
                                              style: AppTextStyles.body2,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  }
                                },
                              ),
                        const SizedBox(height: AppDimensions.paddingL),
                        _buildRatingSection(),
                        const SizedBox(height: AppDimensions.paddingL),
                        ReviewListWidget(merchantId: widget.merchant.id),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool useColumnLayout = constraints.maxWidth < 360;
            if (useColumnLayout) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomButton(
                    text: 'Appeler',
                    type: ButtonType.outline,
                    icon: const Icon(Icons.phone, size: 20),
                    onPressed: () async {
                      await _locationService.makePhoneCall(
                        widget.merchant.phone,
                      );
                    },
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  CustomButton(
                    text: 'Itinéraire',
                    icon: const Icon(Icons.directions, size: 20),
                    onPressed: () async {
                      final success = await _locationService.openNavigation(
                        widget.merchant.latitude,
                        widget.merchant.longitude,
                        widget.merchant.name,
                      );
                      if (!success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Impossible de lancer la navigation externe.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Appeler',
                      type: ButtonType.outline,
                      icon: const Icon(Icons.phone, size: 20),
                      onPressed: () async {
                        await _locationService.makePhoneCall(
                          widget.merchant.phone,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: CustomButton(
                      text: 'Itinéraire',
                      icon: const Icon(Icons.directions, size: 20),
                      onPressed: () async {
                        final success = await _locationService.openNavigation(
                          widget.merchant.latitude,
                          widget.merchant.longitude,
                          widget.merchant.name,
                        );
                        if (!success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Impossible de lancer la navigation externe.',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Avis et notes', style: AppTextStyles.h3),
            Row(
              children: [
                Text(
                  widget.merchant.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Text('(${widget.merchant.reviewCount} avis)'),
              ],
            ),
          ],
        ),
        TextButton(
          onPressed: () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddReviewScreen(merchantId: widget.merchant.id),
              ),
            );
            if (result == true) {
              // Rafraîchir les données si un avis a été ajouté
              setState(() {});
            }
          },
          child: const Text('Laisser un avis'),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatHours(Map<String, dynamic>? hours) {
    if (hours == null || hours.isEmpty) {
      return 'Non disponible';
    }
    // Pour simplifier, on affiche le premier jour disponible.
    // Une logique plus complexe pourrait formater tous les jours.
    final firstDay = hours.keys.first;
    final schedule = hours[firstDay] as Map<String, dynamic>;
    return '$firstDay: ${schedule['open']} - ${schedule['close']}';
  }

  Widget _buildTimeCard(IconData icon, String label, String time) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: AppDimensions.paddingS),
          Text(label, style: AppTextStyles.caption),
          Text(
            time,
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  StatusType _getStatusType() {
    switch (widget.merchant.status) {
      case MerchantStatus.available:
        return StatusType.available;
      case MerchantStatus.lowStock:
        return StatusType.lowStock;
      case MerchantStatus.outOfStock:
        return StatusType.outOfStock;
    }
  }
}
