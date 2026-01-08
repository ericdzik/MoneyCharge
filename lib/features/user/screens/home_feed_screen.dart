import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/constants/app_routes.dart';
import 'package:locacharge/features/user/models/content_item_model.dart';
import 'package:locacharge/features/user/models/advertisement_model.dart';
import 'package:locacharge/features/user/widgets/advertisement_banner_carousel.dart';
import 'package:locacharge/features/user/widgets/nearby_merchants_section.dart';
import 'package:locacharge/features/user/services/feed_manager.dart';
import 'package:locacharge/providers/merchant_provider.dart';
import 'package:locacharge/providers/auth_provider.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({Key? key}) : super(key: key);

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen>
    with AutomaticKeepAliveClientMixin {
  late FeedManager _feedManager;
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _feedManager = FeedManager();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Initialiser le FeedManager avec le MerchantProvider une seule fois
    if (!_isInitialized) {
      _isInitialized = true;
      final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);
      
      print('🔧 Initializing FeedManager with MerchantProvider...');
      _feedManager.initialize(merchantProvider);
      
      // S'assurer que les marchands sont chargés
      if (merchantProvider.merchants.isEmpty && !merchantProvider.isLoading) {
        print('🔄 Rechargement forcé...');
        merchantProvider.listenToMerchants();
      }
      
      // Load initial content après un petit délai
      Future.delayed(const Duration(milliseconds: 100), () {
        _feedManager.loadInitialContent();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _feedManager.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more content when approaching the end
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _feedManager.loadMoreContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
      body: ChangeNotifierProvider.value(
        value: _feedManager,
        child: Consumer<FeedManager>(
          builder: (context, feedManager, child) {
            return NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [_buildAppBar()];
              },
              body: _buildFeedContent(feedManager),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeedContent(FeedManager feedManager) {
    if (feedManager.isLoading && feedManager.contentItems.isEmpty) {
      return const Center(child: LoadingIndicator());
    }

    if (feedManager.errorMessage != null) {
      return _buildErrorState(feedManager.errorMessage!);
    }

    // Séparer les publicités et les marchands
    final advertisements = feedManager.contentItems
        .whereType<AdvertisementContentItem>()
        .map((item) => item.advertisement)
        .toList();

    final merchants = feedManager.contentItems
        .whereType<MerchantContentItem>()
        .toList();

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrousel de bannières publicitaires
            if (advertisements.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.paddingM),
              AdvertisementBannerCarousel(
                advertisements: advertisements,
                onAdTap: (ad) => _handleAdvertisementTap(ad),
                onAdImpression: (adId) => _feedManager.trackAdvertisementImpression(adId),
              ),
            ],
            
            // Section des marchands à proximité
            const SizedBox(height: AppDimensions.paddingL),
            NearbyMerchantsSection(
              merchants: merchants,
              onMerchantTap: _handleMerchantTap,
              radiusKm: 3.0,
              isLoading: feedManager.isLoading && merchants.isEmpty,
            ),
            
            // Espace en bas pour éviter que le contenu soit coupé
            const SizedBox(height: AppDimensions.paddingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              errorMessage,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingL),
            ElevatedButton(
              onPressed: _handleRefresh,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            Text(
              'Accueil',
              style: AppTextStyles.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      leadingWidth: 150,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Découvrez les offres près de chez vous',
                    style: AppTextStyles.body2.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.location_on, color: Colors.white),
          onPressed: _showLocationSettings,
        ),
        IconButton(
          icon: const Icon(Icons.tune, color: Colors.white),
          onPressed: _showFeedSettings,
        ),
      ],
    );
  }

  Future<void> _handleRefresh() async {
    await _feedManager.refreshContent();
  }

  void _handleAdvertisementTap(Advertisement advertisement) {
    // Track click
    _feedManager.trackAdvertisementClick(advertisement.id);
    
    // Navigate to advertisement detail screen
    Navigator.pushNamed(
      context,
      AppRoutes.advertisementDetail,
      arguments: {'advertisement': advertisement},
    );
  }

  void _handleMerchantTap(MerchantContentItem merchant) async {
    try {
      // Récupérer l'objet Merchant complet depuis le MerchantProvider
      final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);
      final fullMerchant = merchantProvider.getMerchantById(merchant.merchantId);
      
      if (fullMerchant != null) {
        Navigator.pushNamed(
          context,
          AppRoutes.merchantDetail,
          arguments: {'merchant': fullMerchant},
        );
      } else {
        // Afficher un message d'erreur si le marchand n'est pas trouvé
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de charger les détails du marchand'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erreur lors de la navigation vers les détails du marchand: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors du chargement'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleItemTap(ContentItem item) {
    switch (item.type) {
      case ContentType.advertisement:
        final adItem = item as AdvertisementContentItem;
        _handleAdvertisementTap(adItem.advertisement);
        break;
      case ContentType.merchant:
        final merchantItem = item as MerchantContentItem;
        _handleMerchantTap(merchantItem);
        break;
      case ContentType.recommendation:
        final recommendationItem = item as RecommendationContentItem;
        _navigateToRecommendation(recommendationItem);
        break;
      default:
        break;
    }
  }

  void _navigateToRecommendation(RecommendationContentItem item) {
    if (item.actionUrl != null) {
      _openUrl(item.actionUrl!);
    }
  }

  void _openUrl(String url) {
    // Implementation for opening URLs
    // This would typically use url_launcher package
    print('Opening URL: $url');
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header du drawer
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        String displayName = 'Utilisateur';
                        String email = '';
                        
                        // Récupérer le nom selon le type d'utilisateur
                        switch (authProvider.userType) {
                          case UserType.user:
                            displayName = authProvider.appUserProfile?.name ?? 'Utilisateur';
                            email = authProvider.appUserProfile?.email ?? '';
                            break;
                          case UserType.merchant:
                            displayName = authProvider.merchantProfile?.businessName ?? 'Marchand';
                            email = authProvider.merchantProfile?.email ?? '';
                            break;
                          case UserType.admin:
                            displayName = authProvider.adminProfile?.name ?? 'Admin';
                            email = authProvider.adminProfile?.email ?? '';
                            break;
                          default:
                            displayName = 'Utilisateur';
                            email = '';
                        }
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: AppTextStyles.h3.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: AppTextStyles.body2.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  title: 'Accueil',
                  onTap: () {
                    Navigator.pop(context);
                  },
                  isSelected: true,
                ),
                _buildDrawerItem(
                  icon: Icons.list,
                  title: 'Liste des marchands',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.listView);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.map,
                  title: 'Carte',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.mapView);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.favorite,
                  title: 'Favoris',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.favorites);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.local_offer,
                  title: 'Promotions',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.promotions);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.notifications);
                  },
                ),
                const Divider(height: 1),
                _buildDrawerItem(
                  icon: Icons.person,
                  title: 'Mon profil',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.userProfile);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help,
                  title: 'Aide et support',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.help);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.privacy_tip,
                  title: 'Confidentialité',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.privacy);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info,
                  title: 'À propos',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.about);
                  },
                ),
              ],
            ),
          ),
          
          // Footer avec déconnexion
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: _buildDrawerItem(
              icon: Icons.logout,
              title: 'Déconnexion',
              onTap: () async {
                Navigator.pop(context);
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
              },
              textColor: AppColors.error,
              iconColor: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? textColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? (isSelected ? AppColors.primary : AppColors.textSecondary),
        ),
        title: Text(
          title,
          style: AppTextStyles.body1.copyWith(
            color: textColor ?? (isSelected ? AppColors.primary : AppColors.textPrimary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
    );
  }

  void _showLocationSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Paramètres de localisation',
              style: AppTextStyles.h3.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('Actualiser ma position'),
              subtitle: const Text('Mettre à jour votre localisation actuelle'),
              onTap: () {
                Navigator.pop(context);
                _feedManager.updateLocation();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres de confidentialité'),
              subtitle: const Text('Gérer vos préférences de localisation'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/privacy-settings');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showFeedSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Paramètres du fil d\'actualité',
              style: AppTextStyles.h3.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Préférences de contenu'),
              subtitle: const Text('Personnaliser votre fil d\'actualité'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/feed-preferences');
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Contenu bloqué'),
              subtitle: const Text('Gérer les marchands et publicités bloqués'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/blocked-content');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}