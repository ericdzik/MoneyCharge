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
      appBar: CustomAppBar(
        title: widget.merchant.name,
        showLogo: false,
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
          Positioned.fill(
            child: Image.asset('assets/splash/33.png', fit: BoxFit.cover),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    double headerHeight = constraints.maxWidth * 0.5;
                    if (headerHeight < 150) headerHeight = 150;
                    if (headerHeight > 300) headerHeight = 300;

                    return Container(
                      width: double.infinity,
                      height: headerHeight,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 255, 255, 255),
                            Color.fromARGB(255, 255, 255, 255),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.store,
                              size: 80,
                              color: Colors.white54,
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
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.merchant.name,
                        style: AppTextStyles.h2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.paddingS),
                      _buildInfoSection(
                        Icons.location_on,
                        'Adresse',
                        widget.merchant.address,
                      ),
                      _buildInfoSection(
                        Icons.phone,
                        'Téléphone',
                        widget.merchant.phone,
                      ),
                      _buildInfoSection(
                        Icons.access_time,
                        'Horaires',
                        '${widget.merchant.hours}\n${widget.merchant.isOpen ? "🟢 Ouvert maintenant" : "🔴 Fermé"}',
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 350) {
                            // Disposition en colonne pour les petits écrans
                            return Column(
                              children: [
                                _buildTimeCard(
                                  Icons.directions_walk,
                                  'À pied',
                                  _walkingTime,
                                ),
                                const SizedBox(height: AppDimensions.paddingS),
                                _buildTimeCard(
                                  Icons.directions_car,
                                  'En voiture',
                                  _drivingTime,
                                ),
                              ],
                            );
                          } else {
                            // Disposition horizontale pour les écrans plus larges
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildTimeCard(
                                    Icons.directions_walk,
                                    'À pied',
                                    _walkingTime,
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.paddingM),
                                Expanded(
                                  child: _buildTimeCard(
                                    Icons.directions_car,
                                    'En voiture',
                                    _drivingTime,
                                  ),
                                ),
                              ],
                            );
                          }
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
                                          maxWidth: constraints.maxWidth * 0.45,
                                        ),
                                        child: Container(
                                          key: ValueKey(service),
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
                    ],
                  ),
                ),
              ],
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

  Widget _buildInfoSection(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingS),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: AppTextStyles.body1,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
