import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/utils/opening_hours_parser.dart';
import 'package:locacharge/core/widgets/status_badge.dart';
import 'package:locacharge/services/directions_service.dart';
import 'package:locacharge/features/user/models/merchant_model.dart';
import 'package:locacharge/features/user/screens/add_review_screen.dart';
import 'package:locacharge/features/user/widgets/review_list_widget.dart';
import 'package:locacharge/providers/location_provider.dart';
import 'package:locacharge/services/location_service.dart';

class MerchantDetailScreen extends StatefulWidget {
  final Merchant merchant;

  const MerchantDetailScreen({super.key, required this.merchant});

  @override
  State<MerchantDetailScreen> createState() => _MerchantDetailScreenState();
}

class _MerchantDetailScreenState extends State<MerchantDetailScreen> {
  String _walkingTime = 'Calcul...';
  String _drivingTime = 'Calcul...';
  final LocationService _locationService = LocationService();
  final DirectionsService _directionsService = DirectionsService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    
    // Retarder le calcul des temps de trajet après la construction du widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateTravelTimes();
    });
  }

  void _handleScroll() {
    setState(() {
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _calculateTravelTimes() async {
    if (!mounted) return;
    
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);

      if (locationProvider.currentPosition == null) {
        await locationProvider.initialize();
      }

      if (!mounted) return;

      final position = locationProvider.currentPosition;
      if (position != null) {
        final origin = LatLng(position.latitude, position.longitude);
        final destination = LatLng(
          widget.merchant.latitude,
          widget.merchant.longitude,
        );

        final results = await Future.wait([
          _directionsService.getDirections(
            origin,
            destination,
            travelMode: 'walking',
          ),
          _directionsService.getDirections(
            origin,
            destination,
            travelMode: 'driving',
          ),
        ]);

        final walking = results[0];
        final driving = results[1];

        if (mounted) {
          if (walking != null && driving != null) {
            setState(() {
              _walkingTime = walking['duration_text'] as String? ?? 'N/A';
              _drivingTime = driving['duration_text'] as String? ?? 'N/A';
            });
          } else {
            final distance = _locationService.calculateDistance(
              position.latitude,
              position.longitude,
              widget.merchant.latitude,
              widget.merchant.longitude,
            );
            setState(() {
              _walkingTime = _locationService.calculateWalkingTime(distance);
              _drivingTime = _locationService.calculateDrivingTime(distance);
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _walkingTime = 'Position ?';
            _drivingTime = 'Position ?';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _walkingTime = 'Erreur';
          _drivingTime = 'Erreur';
        });
      }
    }
  }


  Future<void> _handleNavigation() async {
    final success = await _locationService.openNavigation(
      widget.merchant.latitude,
      widget.merchant.longitude,
      widget.merchant.name,
    );

    if (!success && mounted) {
      SnackBarHelper.showError(
        context,
        'Impossible de lancer la navigation externe.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: widget.merchant.name,
        showLogo: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: const [
          Icon(Icons.store, color: Colors.white),
        ],
        borderRadius: 0,
      ),
      body: _buildMerchantDetail(),
      bottomNavigationBar: _BottomActions(
        phone: widget.merchant.phone,
        onNavigate: _handleNavigation,
      ),
    );
  }

  Widget _buildMerchantDetail() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ImageHero(merchant: widget.merchant),
          _MerchantHeader(merchant: widget.merchant),
          const SizedBox(height: AppDimensions.paddingM),
          _TransitTimesSection(
            walkingTime: _walkingTime,
            drivingTime: _drivingTime,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          _InfoSection(merchant: widget.merchant),
          _ServicesSection(services: widget.merchant.services),
          _RatingSection(merchant: widget.merchant),
          _ReviewSection(merchantId: widget.merchant.id),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ============================================================================
// MODERN UI WIDGETS - SENIOR LEVEL DESIGN
// ============================================================================


class _ImageHero extends StatelessWidget {
  final Merchant merchant;

  const _ImageHero({required this.merchant});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Image with Swiper
        Container(
          height: 300,
          width: double.infinity,
          color: AppColors.surface,
          child: merchant.imageUrls != null && merchant.imageUrls!.isNotEmpty
              ? Swiper(
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: merchant.imageUrls![index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const LoadingIndicator.small(),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.error_outline, size: 40),
                      ),
                    );
                  },
                  itemCount: merchant.imageUrls!.length,
                  pagination: const SwiperPagination(
                    builder: DotSwiperPaginationBuilder(
                      color: Colors.white54,
                      activeColor: Colors.white,
                      size: 8,
                      activeSize: 10,
                    ),
                  ),
                  control: const SwiperControl(
                    color: Colors.white,
                    iconPrevious: Icons.arrow_back_ios,
                    iconNext: Icons.arrow_forward_ios,
                    size: 20,
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.store,
                        size: 80,
                        color: Colors.grey.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      Text(
                        'Aucune image disponible',
                        style: AppTextStyles.body2.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
        ),

        // Gradient Overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Status Badge - Top Right
        Positioned(
          top: AppDimensions.paddingM,
          right: AppDimensions.paddingM,
          child: StatusBadge(
            status: _getStatusType(merchant.status),
          ),
        ),

        // Status Indicator - Bottom Left
        Positioned(
          bottom: AppDimensions.paddingM,
          left: AppDimensions.paddingM,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS,
            ),
            decoration: BoxDecoration(
              color: merchant.isOpen ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  merchant.isOpen ? 'Ouvert maintenant' : 'Fermé',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

StatusType _getStatusType(MerchantStatus status) {
  switch (status) {
    case MerchantStatus.available:
      return StatusType.available;
    case MerchantStatus.lowStock:
      return StatusType.lowStock;
    case MerchantStatus.outOfStock:
      return StatusType.outOfStock;
  }
}

class _MerchantHeader extends StatelessWidget {
  final Merchant merchant;

  const _MerchantHeader({required this.merchant});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchant.name,
                      style: AppTextStyles.h1.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          merchant.merchantType ?? 'Commerce',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          _RatingBadge(merchant: merchant),
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final Merchant merchant;

  const _RatingBadge({required this.merchant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 20),
          const SizedBox(width: 8),
          Text(
            merchant.averageRating.toStringAsFixed(1),
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 4),
          Text(
            '(${merchant.reviewCount} avis)',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransitTimesSection extends StatelessWidget {
  final String walkingTime;
  final String drivingTime;

  const _TransitTimesSection({
    required this.walkingTime,
    required this.drivingTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
      child: Row(
        children: [
          Expanded(
            child: _TransitCard(
              icon: Icons.directions_walk_rounded,
              label: 'À pied',
              time: walkingTime,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: _TransitCard(
              icon: Icons.directions_car_rounded,
              label: 'En voiture',
              time: drivingTime,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransitCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final Color color;

  const _TransitCard({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}


class _InfoSection extends StatelessWidget {
  final Merchant merchant;

  const _InfoSection({required this.merchant});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Informations'),
          const SizedBox(height: AppDimensions.paddingM),
          _InfoTile(
            icon: Icons.location_on_rounded,
            title: 'Adresse',
            content: merchant.address,
            color: Colors.red,
          ),
          const SizedBox(height: AppDimensions.paddingS),
          _InfoTile(
            icon: Icons.phone_rounded,
            title: 'Téléphone',
            content: merchant.phone,
            color: Colors.green,
          ),
          const SizedBox(height: AppDimensions.paddingS),
          _InfoTile(
            icon: Icons.access_time_rounded,
            title: 'Horaires',
            content: _formatHours(merchant.hours),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  String _formatHours(Map<String, dynamic>? hours) {
    return OpeningHoursParser.formatTodayHours(hours, DateTime.now());
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: AppTextStyles.body2.copyWith(
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
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingM),
        Text(title, style: AppTextStyles.h2),
      ],
    );
  }
}

class _ServicesSection extends StatelessWidget {
  final List<String> services;

  const _ServicesSection({required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Services disponibles'),
          const SizedBox(height: AppDimensions.paddingM),
          Wrap(
            spacing: AppDimensions.paddingS,
            runSpacing: AppDimensions.paddingS,
            children: services.map((service) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingS,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  service,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  final Merchant merchant;

  const _RatingSection({required this.merchant});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Avis et notes'),
          const SizedBox(height: AppDimensions.paddingM),
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primary.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          merchant.averageRating.toStringAsFixed(1),
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFC107),
                          size: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${merchant.reviewCount} avis clients',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                CustomButton(
                  text: 'Ajouter',
                  type: ButtonType.primary,
                  onPressed: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddReviewScreen(merchantId: merchant.id),
                      ),
                    );
                    if (result == true && context.mounted) {
                      // Trigger rebuild via Provider
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String merchantId;

  const _ReviewSection({required this.merchantId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Avis récents'),
          const SizedBox(height: AppDimensions.paddingM),
          ReviewListWidget(merchantId: merchantId),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final String phone;
  final VoidCallback onNavigate;

  const _BottomActions({
    required this.phone,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.paddingM,
        right: AppDimensions.paddingM,
        top: AppDimensions.paddingM,
        bottom: AppDimensions.paddingM + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Appeler',
              type: ButtonType.outline,
              icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
              onPressed: () => LocationService().makePhoneCall(phone),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: CustomButton(
              text: 'Itinéraire',
              type: ButtonType.primary,
              icon: const Icon(Icons.directions_rounded, size: 20),
              onPressed: onNavigate,
            ),
          ),
        ],
      ),
    );
  }
}

