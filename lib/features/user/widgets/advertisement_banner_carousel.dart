import 'dart:async';
import 'package:flutter/material.dart';
import 'package:locacharge/core/common.dart';
import 'package:locacharge/features/user/models/advertisement_model.dart';

class AdvertisementBannerCarousel extends StatefulWidget {
  final List<Advertisement> advertisements;
  final Function(Advertisement) onAdTap;
  final Function(String) onAdImpression;

  const AdvertisementBannerCarousel({
    Key? key,
    required this.advertisements,
    required this.onAdTap,
    required this.onAdImpression,
  }) : super(key: key);

  @override
  State<AdvertisementBannerCarousel> createState() => _AdvertisementBannerCarouselState();
}

class _AdvertisementBannerCarouselState extends State<AdvertisementBannerCarousel> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  final Set<String> _viewedAds = <String>{};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    if (widget.advertisements.isNotEmpty) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (widget.advertisements.isEmpty) return;
      
      final nextPage = (_currentPage + 1) % widget.advertisements.length;
      
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _trackImpression(Advertisement ad) {
    if (!_viewedAds.contains(ad.id)) {
      _viewedAds.add(ad.id);
      widget.onAdImpression(ad.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.advertisements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              _trackImpression(widget.advertisements[index]);
            },
            itemCount: widget.advertisements.length,
            itemBuilder: (context, index) {
              final ad = widget.advertisements[index];
              return _buildBannerItem(ad);
            },
          ),
          // Indicateurs de page
          if (widget.advertisements.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: _buildPageIndicators(),
            ),
          // Badge "Sponsorisé"
          Positioned(
            top: 12,
            left: 12,
            child: _buildSponsoredBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerItem(Advertisement ad) {
    return GestureDetector(
      onTap: () => widget.onAdTap(ad),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image de fond
              Image.network(
                ad.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.gray200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.gray200,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
              // Overlay gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              // Contenu texte
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ad.title,
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ad.description,
                      style: AppTextStyles.body2.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.advertisements.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _currentPage == index ? 12 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildSponsoredBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Text(
        'Sponsorisé',
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}