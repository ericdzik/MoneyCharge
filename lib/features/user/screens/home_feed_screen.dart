import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/constants/app_dimensions.dart';
import 'package:locacharge/core/constants/app_routes.dart';
import 'package:locacharge/core/constants/app_text_styles.dart';
import 'package:locacharge/core/constants/app_colors.dart';
import 'package:locacharge/core/utils/responsive_helper.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';
import 'package:locacharge/core/widgets/custom_drawer.dart';
import 'package:locacharge/core/widgets/loading_widgets.dart';
import 'package:locacharge/features/user/widgets/merchant_card.dart';

import 'package:locacharge/features/user/models/advertisement_model.dart';
import 'package:locacharge/features/user/models/content_item_model.dart';
import 'package:locacharge/features/user/screens/advertisement_detail_screen.dart';
import 'package:locacharge/features/user/services/feed_manager.dart';

import 'package:locacharge/providers/merchant_provider.dart';

/// Écran d'accueil avec fil d'actualités
///
/// Affiche :
/// - Une bannière publicitaire en haut (carousel auto-scroll)
/// - Une liste de marchands à proximité
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  late FeedManager _feedManager;

  // Contrôleur pour le carousel de bannières publicitaires
  final PageController _bannerController = PageController(
    viewportFraction: 0.9,
  );
  int _currentBannerIndex = 0;

  // Timer pour l'auto-scroll des bannières
  Timer? _bannerAutoScrollTimer;
  bool _isBannerPaused = false;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    _feedManager = context.read<FeedManager>();
    final merchantProvider = context.read<MerchantProvider>();

    // Initialiser et charger le contenu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _feedManager.initialize(merchantProvider);
      _feedManager.loadInitialContent();
    });

    _initialized = true;
  }

  @override
  void dispose() {
    _bannerAutoScrollTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  /* -------------------------------------------------------------------------- */
  /*                            AUTO-SCROLL BANNER                              */
  /* -------------------------------------------------------------------------- */

  void _startBannerAutoScroll(int bannerCount) {
    if (bannerCount <= 1) return;

    _bannerAutoScrollTimer?.cancel();
    _bannerAutoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _isBannerPaused) return;

      final nextIndex = (_currentBannerIndex + 1) % bannerCount;
      _bannerController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void _pauseBannerAutoScroll() {
    setState(() => _isBannerPaused = true);
  }

  void _resumeBannerAutoScroll() {
    setState(() => _isBannerPaused = false);
  }

  /* -------------------------------------------------------------------------- */
  /*                                   BUILD                                    */
  /* -------------------------------------------------------------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: 'Accueil',
      showLogo: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.location_on, color: Colors.white),
          onPressed: _showLocationSettings,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return ListenableBuilder(
      listenable: _feedManager,
      builder: (context, _) {
        // État de chargement initial
        if (_feedManager.isLoading && _feedManager.contentItems.isEmpty) {
          return const Center(child: LoadingIndicator());
        }

        // État d'erreur
        if (_feedManager.errorMessage != null) {
          return _buildErrorState(_feedManager.errorMessage!);
        }

        // Extraire les bannières publicitaires et les marchands
        final banners = _feedManager.contentItems
            .whereType<AdvertisementContentItem>()
            .toList();

        final merchants = _feedManager.contentItems
            .whereType<MerchantContentItem>()
            .toList();

        // Démarrer l'auto-scroll si nécessaire
        if (banners.isNotEmpty && _bannerAutoScrollTimer == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _startBannerAutoScroll(banners.length);
          });
        }

        return RefreshIndicator(
          onRefresh: _feedManager.refreshContent,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Bannière publicitaire en haut
              if (banners.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: AppDimensions.paddingM,
                      bottom: AppDimensions.paddingL,
                    ),
                    child: _buildBannerCarousel(banners),
                  ),
                ),

              // Section titre "Marchands à proximité"
              if (merchants.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                    ),
                    child: Text(
                      'Marchands à proximité',
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              if (merchants.isNotEmpty)
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimensions.paddingM),
                ),

              // Liste des marchands
              if (merchants.isEmpty && banners.isEmpty)
                SliverFillRemaining(child: _buildEmptyState())
              else if (merchants.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.paddingM,
                    0,
                    AppDimensions.paddingM,
                    100,
                  ), // Espace pour nav bar + marges latérales
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final merchant = merchants[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingM,
                        ),
                        child: MerchantCard(
                          merchantId: merchant.merchantId,
                          name: merchant.name,
                          services: merchant.services,
                          rating: merchant.rating,
                          distanceKm: merchant.distanceKm,
                          imageUrl: merchant.imageUrl,
                          address: merchant.address,
                          isVerified: merchant.isVerified,
                          onTap: () => _onMerchantTap(merchant),
                        ),
                      );
                    }, childCount: merchants.length),
                  ),
                )
              else
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        );
      },
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                            BANNER CAROUSEL                                 */
  /* -------------------------------------------------------------------------- */

  Widget _buildBannerCarousel(List<AdvertisementContentItem> banners) {
    return Column(
      children: [
        const SizedBox(height: 8),

        // Carousel avec effet "Peek" (viewportFraction)
        SizedBox(
          height: ResponsiveHelper.getImageHeight(
            context,
            extraSmall: 160.0,
            small: 170.0,
            medium: 190.0,
            large: 200.0,
            tablet: 220.0,
          ),
          child: GestureDetector(
            onTapDown: (_) => _pauseBannerAutoScroll(),
            onTapUp: (_) => _resumeBannerAutoScroll(),
            onTapCancel: () => _resumeBannerAutoScroll(),
            child: PageView.builder(
              controller: _bannerController,
              itemCount: banners.length,
              padEnds: true,
              onPageChanged: (index) {
                setState(() => _currentBannerIndex = index);
                _feedManager.trackAdvertisementImpression(banners[index].id);
              },
              itemBuilder: (context, index) {
                return _buildPremiumBannerCard(banners[index]);
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Indicateurs de page centrés en dessous
        if (banners.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              banners.length,
              (index) =>
                  _buildPageIndicator(isActive: index == _currentBannerIndex),
            ),
          ),
      ],
    );
  }

  Widget _buildPremiumBannerCard(AdvertisementContentItem item) {
    return GestureDetector(
      onTap: () => _onBannerTap(item.advertisement),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: context.isExtraSmall ? 4 : 6,
        ), // Espacement entre les cartes
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getBorderRadius(context, baseRadius: 24),
          ),
          color: AppColors.gray200, // Placeholder couleur
          image: DecorationImage(
            image: NetworkImage(item.advertisement.imageUrl),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Dégradé Noir -> Transparent (Pour lisibilité texte à gauche)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.0, 0.7],
                ),
              ),
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 0),

                  const Spacer(),

                  // Titre
                  Text(
                    item.advertisement.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.getFontSize(
                        context,
                        baseSize: 22,
                      ),
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Description (ex: Up to 40%)
                  if (item.advertisement.description.isNotEmpty)
                    Text(
                      item.advertisement.description,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveHelper.getFontSize(
                          context,
                          baseSize: 14,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 12),

                  // Bouton "Claim" / "Voir l'offre" aligné à droite
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        item.advertisement.callToAction ?? "Voir l'offre",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.getFontSize(
                            context,
                            baseSize: 12,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.gray300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                                EMPTY STATE                                 */
  /* -------------------------------------------------------------------------- */

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
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
                size: 60,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            Text(
              'Aucun contenu disponible',
              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              'Tirez vers le bas pour actualiser',
              textAlign: TextAlign.center,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                              ERROR STATE                                   */
  /* -------------------------------------------------------------------------- */

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppDimensions.paddingL),
            Text(
              'Erreur',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body1,
            ),
            const SizedBox(height: AppDimensions.paddingL),
            ElevatedButton.icon(
              onPressed: () => _feedManager.refreshContent(),
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

  /* -------------------------------------------------------------------------- */
  /*                                ACTIONS                                     */
  /* -------------------------------------------------------------------------- */

  void _onBannerTap(Advertisement ad) {
    _feedManager.trackAdvertisementClick(ad.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdvertisementDetailScreen(advertisement: ad),
      ),
    );
  }

  void _onMerchantTap(MerchantContentItem merchant) {
    final provider = context.read<MerchantProvider>();
    final model = provider.getMerchantById(merchant.merchantId);

    if (model == null) {
      _showSnackBar('Marchand introuvable');
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.merchantDetail,
      arguments: {'merchant': model},
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showLocationSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Paramètres de localisation', style: AppTextStyles.h2),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              'Activez la localisation pour voir les marchands à proximité',
              style: AppTextStyles.body1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingL),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }
}
