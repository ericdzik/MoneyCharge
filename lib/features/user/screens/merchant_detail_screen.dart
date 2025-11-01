import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:card_swiper/card_swiper.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/background_image_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/merchant_model.dart';
import '../../../services/location_service.dart';
import 'package:locacharge/features/user/screens/add_review_screen.dart';
import 'package:locacharge/features/user/widgets/review_list_widget.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/favorite_merchant_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _calculateTravelTimes();
  }

  Future<void> _calculateTravelTimes() async {
    final locationProvider = context.read<LocationProvider>();

    if (locationProvider.currentPosition == null) {
      await locationProvider.initialize();
    }

    if (!mounted) return;

    final position = locationProvider.currentPosition;
    if (position != null) {
      final distance = _locationService.calculateDistance(
        position.latitude,
        position.longitude,
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

  void _shareMerchant() {
    final merchant = widget.merchant;
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${merchant.latitude},${merchant.longitude}';

    final services = merchant.services.join('\n- ');
    final servicesText =
        services.isNotEmpty ? 'Services proposés :\n- $services\n\n' : '';

    final shareMessage = 'Découvrez ce marchand sur Géo : ${merchant.name}\n\n'
        '$servicesText'
        '📍 Emplacement sur Google Maps :\n$googleMapsUrl';

    Share.share(shareMessage);
  }

  Future<void> _handleNavigation() async {
    final success = await _locationService.openNavigation(
      widget.merchant.latitude,
      widget.merchant.longitude,
      widget.merchant.name,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de lancer la navigation externe.'),
        ),
      );
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
          _FavoriteButton(merchantId: widget.merchant.id),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareMerchant,
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: BackgroundImage()),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.paddingM),
                  _ImageCarousel(merchant: widget.merchant),
                  _ContentCard(
                    merchant: widget.merchant,
                    walkingTime: _walkingTime,
                    drivingTime: _drivingTime,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomActions(
        phone: widget.merchant.phone,
        onNavigate: _handleNavigation,
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final String merchantId;

  const _FavoriteButton({required this.merchantId});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteMerchantProvider>(
      builder: (context, provider, _) {
        final isFavorite = provider.isFavorite(merchantId);
        return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? AppColors.error : null,
          ),
          onPressed: () {
            if (isFavorite) {
              provider.removeFavorite(merchantId);
            } else {
              provider.addFavorite(merchantId);
            }
          },
        );
      },
    );
  }
}

class _ImageCarousel extends StatelessWidget {
  final Merchant merchant;

  const _ImageCarousel({required this.merchant});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        child: Stack(
          children: [
            if (merchant.imageUrls != null && merchant.imageUrls!.isNotEmpty)
              Swiper(
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: merchant.imageUrls![index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  );
                },
                itemCount: merchant.imageUrls!.length,
                pagination: const SwiperPagination(
                  builder: DotSwiperPaginationBuilder(
                    color: Colors.white54,
                    activeColor: AppColors.primary,
                  ),
                ),
                control: const SwiperControl(color: AppColors.primary),
              )
            else
              const Center(
                child: Icon(Icons.store, size: 60, color: Colors.grey),
              ),
            Positioned(
              top: AppDimensions.paddingM,
              right: AppDimensions.paddingM,
              child: StatusBadge(status: _getStatusType(merchant.status)),
            ),
          ],
        ),
      ),
    );
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
}

class _ContentCard extends StatelessWidget {
  final Merchant merchant;
  final String walkingTime;
  final String drivingTime;

  const _ContentCard({
    required this.merchant,
    required this.walkingTime,
    required this.drivingTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      margin: const EdgeInsets.all(AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoCard(
            icon: Icons.storefront,
            title: 'Nom du commerce',
            content: merchant.name,
          ),
          _InfoCard(
            icon: Icons.business,
            title: 'Type de commerce',
            content: merchant.merchantType ?? 'Non spécifié',
          ),
          _InfoCard(
            icon: Icons.location_on,
            title: 'Adresse',
            content: merchant.address,
          ),
          _InfoCard(
            icon: Icons.phone,
            title: 'Téléphone',
            content: merchant.phone,
          ),
          _InfoCard(
            icon: Icons.access_time,
            title: 'Horaires',
            content:
                '${_formatHours(merchant.hours)}\n${merchant.isOpen ? "🟢 Ouvert maintenant" : "🔴 Fermé"}',
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Row(
            children: [
              Expanded(
                child: _TimeCard(
                  icon: Icons.directions_walk,
                  label: 'À pied',
                  time: walkingTime,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingS),
              Expanded(
                child: _TimeCard(
                  icon: Icons.directions_car,
                  label: 'En voiture',
                  time: drivingTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingL),
          Text('Services disponibles', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.paddingM),
          _ServicesList(services: merchant.services),
          const SizedBox(height: AppDimensions.paddingL),
          _RatingSection(merchant: merchant),
          const SizedBox(height: AppDimensions.paddingL),
          ReviewListWidget(merchantId: merchant.id),
        ],
      ),
    );
  }

  String _formatHours(Map<String, dynamic>? hours) {
    if (hours == null || hours.isEmpty) return 'Non disponible';
    final firstDay = hours.keys.first;
    final schedule = hours[firstDay] as Map<String, dynamic>;
    return '$firstDay: ${schedule['open']} - ${schedule['close']}';
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _TimeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;

  const _TimeCard({
    required this.icon,
    required this.label,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _ServicesList extends StatelessWidget {
  final List<String> services;

  const _ServicesList({required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Text('Aucun service disponible.');
    }

    return Wrap(
      spacing: AppDimensions.paddingS,
      runSpacing: AppDimensions.paddingS,
      children: services.map((service) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            service,
            style: AppTextStyles.body2,
          ),
        );
      }).toList(),
    );
  }
}

class _RatingSection extends StatelessWidget {
  final Merchant merchant;

  const _RatingSection({required this.merchant});

  @override
  Widget build(BuildContext context) {
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
                  merchant.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Text('(${merchant.reviewCount} avis)'),
              ],
            ),
          ],
        ),
        TextButton(
          onPressed: () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => AddReviewScreen(merchantId: merchant.id),
              ),
            );
            if (result == true && context.mounted) {
              // Trigger rebuild via Provider or callback
            }
          },
          child: const Text('Laisser un avis'),
        ),
      ],
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
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Appeler',
              type: ButtonType.outline,
              icon: const Icon(Icons.phone, size: 20),
              onPressed: () => LocationService().makePhoneCall(phone),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: CustomButton(
              text: 'Itinéraire',
              icon: const Icon(Icons.directions, size: 20),
              onPressed: onNavigate,
            ),
          ),
        ],
      ),
    );
  }
}
