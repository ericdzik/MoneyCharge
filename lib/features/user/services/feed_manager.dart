import 'package:geolocator/geolocator.dart';
import 'package:locacharge/features/user/models/merchant_model.dart';
import 'package:locacharge/models/ad_model.dart';
import 'package:locacharge/providers/ad_provider.dart';
import 'package:locacharge/providers/merchant_provider.dart';
import 'package:locacharge/services/location_service.dart';

/// Types de contenu pour le fil
enum ContentItemType { advertisement, merchant, recommendation }

/// Modèle de base pour le contenu
abstract class ContentItem {
  final String id;
  final DateTime timestamp;
  ContentItem(this.id, this.timestamp);
  ContentItemType get type;
}

class AdvertisementContentItem extends ContentItem {
  final Ad ad;
  AdvertisementContentItem({required String id, required this.ad, required DateTime timestamp})
      : super(id, timestamp);
  @override
  ContentItemType get type => ContentItemType.advertisement;
}

class MerchantContentItem extends ContentItem {
  final Merchant merchant;
  MerchantContentItem({required String id, required this.merchant, required DateTime timestamp})
      : super(id, timestamp);
  @override
  ContentItemType get type => ContentItemType.merchant;
}

class RecommendationContentItem extends ContentItem {
  final String title;
  final String description;
  final String imageUrl;
  final String actionUrl;
  final Map<String, String> metadata;
  RecommendationContentItem({
    required String id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.actionUrl,
    required this.metadata,
    required DateTime timestamp,
  }) : super(id, timestamp);
  @override
  ContentItemType get type => ContentItemType.recommendation;
}
=======
import 'package:geolocator/geolocator.dart';
import 'package:locacharge/features/user/models/merchant_model.dart';
import 'package:locacharge/models/ad_model.dart';
import 'package:locacharge/providers/ad_provider.dart';
import 'package:locacharge/providers/merchant_provider.dart';
import 'package:locacharge/services/location_service.dart';

/// Types de contenu pour le fil
enum ContentItemType { advertisement, merchant, recommendation }

/// Modèle de base pour le contenu
abstract class ContentItem {
  final String id;
  final DateTime timestamp;
  ContentItem(this.id, this.timestamp);
  ContentItemType get type;
}

class AdvertisementContentItem extends ContentItem {
  final Ad ad;
  AdvertisementContentItem({required String id, required this.ad, required DateTime timestamp})
      : super(id, timestamp);
  @override
  ContentItemType get type => ContentItemType.advertisement;
}

class MerchantContentItem extends ContentItem {
  final Merchant merchant;
  MerchantContentItem({required String id, required this.merchant, required DateTime timestamp})
      : super(id, timestamp);
  @override
  ContentItemType get type => ContentItemType.merchant;
}

class RecommendationContentItem extends ContentItem {
  final String title;
  final String description;
  final String imageUrl;
  final String actionUrl;
  final Map<String, String> metadata;
  RecommendationContentItem({
    required String id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.actionUrl,
    required this.metadata,
    required DateTime timestamp,
  }) : super(id, timestamp);
  @override
  ContentItemType get type => ContentItemType.recommendation;
}

class FeedManager extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  MerchantProvider? _merchantProvider;
  final AdProvider _adProvider = AdProvider();
>>>>>>> 8579596d (Commit de toutes les modifications récentes :)

  List<ContentItem> _contentItems = [];
  bool _isLoading = false;
  String? _errorMessage;
<<<<<<< HEAD
  Location? _currentLocation;
=======
  Position? _currentLocation;
>>>>>>> 8579596d (Commit de toutes les modifications récentes :)
  int _currentPage = 0;
  static const int _pageSize = 10;
  bool _hasMoreContent = true;

  // Getters
  List<ContentItem> get contentItems => _contentItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMoreContent => _hasMoreContent;

  /// Initialiser le FeedManager avec le MerchantProvider
  void initialize(MerchantProvider merchantProvider) {
<<<<<<< HEAD
    print('🔧 FeedManager: Initializing with MerchantProvider...');
    _merchantProvider = merchantProvider;
    _merchantService.initialize(merchantProvider);
    print('🔧 FeedManager: MerchantProvider initialized successfully');
  }

  /// Load initial content for the feed
=======
    _merchantProvider = merchantProvider;
  }

  /// Charger le contenu initial du fil
>>>>>>> 8579596d (Commit de toutes les modifications récentes :)
  Future<void> loadInitialContent() async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();
    _currentPage = 0;
    _hasMoreContent = true;

    try {
<<<<<<< HEAD
      // Get current location with timeout to avoid blocking
      await _updateCurrentLocationWithTimeout();

      // Load initial content with optimized approach
      final content = await _loadContentPageOptimized(0);
      _contentItems = content;
      
      print('FeedManager: Loaded ${content.length} content items');
      print('FeedManager: Content types: ${content.map((c) => c.type.toString()).join(', ')}');
      
=======
      await _updateCurrentLocationWithTimeout();
      final content = await _loadContentPage(0);
      _contentItems = content;
>>>>>>> 8579596d (Commit de toutes les modifications récentes :)
      if (content.length < _pageSize) {
        _hasMoreContent = false;
      }
    } catch (e) {
<<<<<<< HEAD
      print('FeedManager: Error loading initial content: $e');
=======
>>>>>>> 8579596d (Commit de toutes les modifications récentes :)
      _setError('Erreur lors du chargement du contenu: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

<<<<<<< HEAD
  /// Load more content for pagination
  Future<void> loadMoreContent() async {
    if (_isLoading || !_hasMoreContent) return;

    _setLoading(true);
    _clearError();

    try {
      final nextPage = _currentPage + 1;
      final newContent = await _loadContentPage(nextPage);
      
      if (newContent.isNotEmpty) {
        _contentItems.addAll(newContent);
        _currentPage = nextPage;
        
=======
  /// Charger plus de contenu (pagination)
  Future<void> loadMoreContent() async {
    if (_isLoading || !_hasMoreContent) return;
    _setLoading(true);
    _clearError();
    try {
      final nextPage = _currentPage + 1;
      final newContent = await _loadContentPage(nextPage);
      if (newContent.isNotEmpty) {
        _contentItems.addAll(newContent);
        _currentPage = nextPage;
>>>>>>> 8579596d (Commit de toutes les modifications récentes :)
        if (newContent.length < _pageSize) {
          _hasMoreContent = false;
        }
      } else {
        _hasMoreContent = false;
      }
    } catch (e) {
      _setError('Erreur lors du chargement de contenu supplémentaire: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

<<<<<<< HEAD
  /// Refresh all content
=======
  /// Rafraîchir tout le contenu
>>>>>>> 8579596d (Commit de toutes les modifications récentes :)
  Future<void> refreshContent() async {
    await loadInitialContent();
    _setLoading(true);
    _clearError();
    try {
      final nextPage = _currentPage + 1;
      final newContent = await _loadContentPage(nextPage);
      if (newContent.isNotEmpty) {
        _contentItems.addAll(newContent);
        _currentPage = nextPage;
        if (newContent.length < _pageSize) {
          _hasMoreContent = false;
        }
      } else {
        _hasMoreContent = false;
      }
    } catch (e) {
      _setError('Erreur lors du chargement de contenu supplémentaire: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  /// Track advertisement click
  void trackAdvertisementClick(String advertisementId) {
    // For now, just log the click since the old system doesn't have analytics
    print('Advertisement clicked: $advertisementId');
    // You could add analytics tracking here in the future
  }

  /// Track advertisement impression
  void trackAdvertisementImpression(String advertisementId) {
    // For now, just log the impression since the old system doesn't have analytics
    print('Advertisement impression: $advertisementId');
    // You could add analytics tracking here in the future
  }

  /// Load a specific page of content
  Future<List<ContentItem>> _loadContentPage(int page) async {
    final List<ContentItem> pageContent = [];

    // Calculate offset
    final offset = page * _pageSize;

    // Load advertisements
    final advertisements = await _loadAdvertisements(offset, _pageSize ~/ 2);
    
    // Load nearby merchants
    final merchants = await _loadNearbyMerchants(offset, _pageSize ~/ 3);
    
    // Load recommendations
    final recommendations = await _loadRecommendations(offset, _pageSize ~/ 5);

    // Create structured content based on requirements
    if (page == 0) {
      // First page: Banner ad, merchants section, sponsored content, recommendations
      pageContent.addAll(_createStructuredFirstPage(advertisements, merchants, recommendations));
    } else {
      // Subsequent pages: Mix content with advertisements
      pageContent.addAll(_createMixedContent(advertisements, merchants, recommendations));
    }

    return pageContent;
  }

  /// Load targeted advertisements
  Future<List<Advertisement>> _loadAdvertisements(int offset, int limit) async {
    try {
      print('FeedManager: Loading advertisements...');
      
      // Fetch ads from the existing AdProvider system
      await _adProvider.fetchAds();
      final ads = _adProvider.ads;
      
      print('FeedManager: Found ${ads.length} ads in database');
      
      if (ads.isEmpty) {
        print('FeedManager: No ads found in the system');
        return [];
      }

      // Convert Ad objects to Advertisement objects
      final advertisements = ads.map((ad) => _convertAdToAdvertisement(ad)).toList();
      
      print('FeedManager: Converted ${advertisements.length} ads to advertisements');
      
      // Apply location-based filtering if available
      if (_currentLocation != null) {
        // For now, show all ads since the old system doesn't have location targeting
        // In the future, you could add location filtering here
        final result = advertisements.skip(offset).take(limit).toList();
        print('FeedManager: Returning ${result.length} advertisements (with location)');
        return result;
      } else {
        final result = advertisements.skip(offset).take(limit).toList();
        print('FeedManager: Returning ${result.length} advertisements (without location)');
        return result;
      }
    } catch (e) {
      print('FeedManager: Error loading advertisements: $e');
=======
  /// Tracking (placeholder)
  void trackAdvertisementClick(String advertisementId) {}
  void trackAdvertisementImpression(String advertisementId) {}

  /// Charger une page spécifique de contenu
  Future<List<ContentItem>> _loadContentPage(int page) async {
    final List<ContentItem> pageContent = [];
    final offset = page * _pageSize;

    final advertisements = await _loadAdvertisements(offset, _pageSize ~/ 2);
    final merchants = await _loadNearbyMerchants(offset, _pageSize ~/ 3);
    final recommendations = await _loadRecommendations(offset, _pageSize ~/ 5);

    if (page == 0) {
      pageContent.addAll(_createStructuredFirstPage(advertisements, merchants, recommendations));
    } else {
      pageContent.addAll(_createMixedContent(advertisements, merchants, recommendations));
    }
    return pageContent;
  }

  /// Charger des publicités ciblées
  Future<List<Ad>> _loadAdvertisements(int offset, int limit) async {
    try {
      await _adProvider.fetchAds();
      final ads = _adProvider.ads;
      if (ads.isEmpty) return [];
      return ads.skip(offset).take(limit).toList();
    } catch (_) {
>>>>>>> 8579596d (Commit de toutes les modifications récentes :)
      return [];
    }
  }

<<<<<<< HEAD
  /// Convert Ad model to Advertisement model
  Advertisement _convertAdToAdvertisement(Ad ad) {
    return Advertisement(
      id: ad.id,
      title: ad.title,
      description: ad.description,
      imageUrl: ad.imageUrl,
      merchantId: 'unknown', // The old Ad model doesn't have merchantId
      targetLocation: null, // The old Ad model doesn't have location targeting
      targetRadiusKm: null,
      type: AdvertisementType.banner,
      createdAt: ad.createdAt.toDate(),
      expiresAt: null, // The old Ad model doesn't have expiration
      isActive: true, // Assume all ads in the system are active
      targetingCriteria: {}, // The old Ad model doesn't have targeting criteria
      callToAction: 'Voir plus', // Default call to action
    );
  }

  /// Load nearby merchants with 3km radius filter using optimized service
  Future<List<MerchantContentItem>> _loadNearbyMerchants(int offset, int limit) async {
    print('🔍 FeedManager: _loadNearbyMerchants called');
    
    try {
      // Utiliser le service optimisé pour la recherche de marchands
      final nearbyMerchants = await _merchantService.findMerchantsWithin3Km(
        userLocation: _currentLocation,
        limit: limit,
      );
      
      print('🔍 FeedManager: MerchantService returned ${nearbyMerchants.length} merchants');
      
      // Appliquer la pagination si nécessaire
      final result = nearbyMerchants.skip(offset).take(limit).toList();
      
      print('🔍 FeedManager: Returning ${result.length} merchants after pagination');
      return result;
    } catch (e) {
      print('❌ FeedManager: Error loading merchants: $e');
=======
  /// Charger des marchands proches (rayon 3 km)
  Future<List<MerchantContentItem>> _loadNearbyMerchants(int offset, int limit) async {
    try {
      final merchants = _merchantProvider?.merchants ?? [];
      List<Merchant> filtered = merchants;
      if (_currentLocation != null) {
        filtered = merchants.where((m) {
          final distMeters = _locationService.calculateDistance(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
            m.latitude,
            m.longitude,
          );
          return distMeters <= 3000; // 3 km
        }).toList();
      }
      final items = filtered.map((m) => MerchantContentItem(
        id: 'merchant_${m.id}',
        merchant: m,
        timestamp: DateTime.now(),
      )).toList();
      return items.skip(offset).take(limit).toList();
    } catch (_) {
>>>>>>> 8579596d (Commit de toutes les modifications récentes :)
      return [];
    }
  }

<<<<<<< HEAD
  /// Load content recommendations
  Future<List<RecommendationContentItem>> _loadRecommendations(int offset, int limit) async {
    try {
      // This would typically call a recommendation service
      // For now, return mock data
      final mockRecommendations = _createMockRecommendations();
      return mockRecommendations.skip(offset).take(limit).toList();
    } catch (e) {
      print('Error loading recommendations: $e');
=======
  /// Charger des recommandations (mock pour l'instant)
  Future<List<RecommendationContentItem>> _loadRecommendations(int offset, int limit) async {
    try {
      final mock = _createMockRecommendations();
      return mock.skip(offset).take(limit).toList();
    } catch (_) {
>>>>>>> 8579596d (Commit de toutes les modifications récentes :)
      return [];
    }
  }

<<<<<<< HEAD
  /// Create structured content for the first page
  List<ContentItem> _createStructuredFirstPage(
    List<Advertisement> advertisements,
    List<MerchantContentItem> merchants,
    List<RecommendationContentItem> recommendations,
  ) {
    print('🔍 FeedManager: _createStructuredFirstPage called with ${merchants.length} merchants');
    
    final List<ContentItem> content = [];

    // 1. Banner advertisement (if available)
    if (advertisements.isNotEmpty) {
      content.add(AdvertisementContentItem(
        id: 'banner_${advertisements.first.id}',
        advertisement: advertisements.first,
        timestamp: DateTime.now(),
      ));
      print('🔍 FeedManager: Added banner ad');
    }

    // 2. Add merchants directly as MerchantContentItem (not in a section)
    if (merchants.isNotEmpty) {
      content.addAll(merchants.take(10)); // Limit to 10 merchants
      print('🔍 FeedManager: Added ${merchants.take(10).length} merchants to content');
    } else {
      print('❌ FeedManager: No merchants to add to content');
    }

    // 3. Sponsored content (remaining advertisements)
=======
  /// Contenu structuré pour la première page
  List<ContentItem> _createStructuredFirstPage(
    List<Ad> advertisements,
    List<MerchantContentItem> merchants,
    List<RecommendationContentItem> recommendations,
  ) {
    final List<ContentItem> content = [];

    if (advertisements.isNotEmpty) {
      content.add(AdvertisementContentItem(
        id: 'banner_${advertisements.first.id}',
        ad: advertisements.first,
        timestamp: DateTime.now(),
      ));
    }

    if (merchants.isNotEmpty) {
      content.addAll(merchants.take(10));
    }

>>>>>>> 8579596d (Commit de toutes les modifications récentes :)
    if (advertisements.length > 1) {
      for (int i = 1; i < advertisements.length; i++) {
        content.add(AdvertisementContentItem(
          id: 'sponsored_${advertisements[i].id}',
<<<<<<< HEAD
          advertisement: advertisements[i],
          timestamp: DateTime.now(),
        ));
      }
      print('🔍 FeedManager: Added ${advertisements.length - 1} sponsored ads');
    }

    // 4. Recommendations
    content.addAll(recommendations);
    print('🔍 FeedManager: Added ${recommendations.length} recommendations');

    print('🔍 FeedManager: Total content items: ${content.length}');
    return content;
  }

  /// Create mixed content for subsequent pages
  List<ContentItem> _createMixedContent(
    List<Advertisement> advertisements,
=======
          ad: advertisements[i],
          timestamp: DateTime.now(),
        ));
      }
    }

    content.addAll(recommendations);
    return content;
  }

  /// Contenu mixte pour les pages suivantes
  List<ContentItem> _createMixedContent(
    List<Ad> advertisements,
>>>>>>> 8579596d (Commit de toutes les modifications récentes :)
    List<MerchantContentItem> merchants,
    List<RecommendationContentItem> recommendations,
  ) {
    final List<ContentItem> content = [];
    final List<ContentItem> allContent = [];

<<<<<<< HEAD
    // Add all content to a single list
    allContent.addAll(advertisements.map((ad) => AdvertisementContentItem(
      id: 'ad_${ad.id}',
      advertisement: ad,
=======
    allContent.addAll(advertisements.map((ad) => AdvertisementContentItem(
      id: 'ad_${ad.id}',
      ad: ad,
>>>>>>> 8579596d (Commit de toutes les modifications récentes :)
      timestamp: DateTime.now(),
    )));
    allContent.addAll(merchants);
    allContent.addAll(recommendations);

<<<<<<< HEAD
    // Mix content with advertisements every 3-4 items
    int adIndex = 0;
    for (int i = 0; i < allContent.length; i++) {
      content.add(allContent[i]);
      
      // Insert advertisement every 3-4 items
      if ((i + 1) % 3 == 0 && adIndex < advertisements.length) {
        content.add(AdvertisementContentItem(
          id: 'mixed_ad_${advertisements[adIndex].id}',
          advertisement: advertisements[adIndex],
=======
    int adIndex = 0;
    for (int i = 0; i < allContent.length; i++) {
      content.add(allContent[i]);
      if ((i + 1) % 3 == 0 && adIndex < advertisements.length) {
        content.add(AdvertisementContentItem(
          id: 'mixed_ad_${advertisements[adIndex].id}',
          ad: advertisements[adIndex],
>>>>>>> 8579596d (Commit de toutes les modifications récentes :)
          timestamp: DateTime.now(),
        ));
        adIndex++;
      }
    }
<<<<<<< HEAD

    return content;
  }

  /// Update current location with timeout to avoid blocking
  Future<void> _updateCurrentLocationWithTimeout() async {
    try {
      // Use a timeout to avoid blocking the UI
      await Future.any([
        _updateCurrentLocation(),
        Future.delayed(const Duration(seconds: 5)), // 5 second timeout
      ]);
    } catch (e) {
      print('FeedManager: Location update timed out or failed: $e');
      // Continue without location - will show general content
    }
  }

  /// Load a specific page of content with optimized approach
  Future<List<ContentItem>> _loadContentPageOptimized(int page) async {
    final List<ContentItem> pageContent = [];

    // Calculate offset
    final offset = page * _pageSize;

    try {
      // Load content in parallel for better performance
      final futures = await Future.wait([
        _loadAdvertisements(offset, _pageSize ~/ 2),
        _loadNearbyMerchants(offset, _pageSize ~/ 3),
        _loadRecommendations(offset, _pageSize ~/ 5),
      ]);

      final advertisements = futures[0] as List<Advertisement>;
      final merchants = futures[1] as List<MerchantContentItem>;
      final recommendations = futures[2] as List<RecommendationContentItem>;

      // Create structured content based on requirements
      if (page == 0) {
        // First page: Banner ad, merchants section, sponsored content, recommendations
        pageContent.addAll(_createStructuredFirstPage(advertisements, merchants, recommendations));
      } else {
        // Subsequent pages: Mix content with advertisements
        pageContent.addAll(_createMixedContent(advertisements, merchants, recommendations));
      }

      return pageContent;
    } catch (e) {
      print('FeedManager: Error in optimized content loading: $e');
      // Fallback to original method
      return await _loadContentPage(page);
    }
  }
  Future<void> _updateCurrentLocation() async {
    try {
      final permissionStatus = await _geolocationService.requestPermission();
      if (permissionStatus == LocationPermissionStatus.granted) {
        _currentLocation = await _geolocationService.getCurrentLocation();
        print('FeedManager: Location updated: ${_currentLocation?.latitude}, ${_currentLocation?.longitude}');
      } else {
        print('FeedManager: Location permission not granted: $permissionStatus');
        // Use fallback location or continue without location
        _currentLocation = _geolocationService.getFallbackLocation();
      }
    } catch (e) {
      print('FeedManager: Error updating location: $e');
      // Continue without location - will show general content
=======
    return content;
  }

  /// Mettre à jour la localisation avec un timeout pour éviter le blocage
  Future<void> _updateCurrentLocationWithTimeout() async {
    try {
      await Future.any([
        _updateCurrentLocation(),
        Future.delayed(const Duration(seconds: 5)),
      ]);
    } catch (_) {}
  }

  /// Mettre à jour la localisation courante via LocationService
  Future<void> _updateCurrentLocation() async {
    try {
      final permissionStatus = await _locationService.requestPermission();
      if (permissionStatus == LocationPermission.always || permissionStatus == LocationPermission.whileInUse) {
        _currentLocation = await _locationService.getCurrentPosition();
      } else {
        _currentLocation = null;
      }
    } catch (_) {
>>>>>>> 8579596d (Commit de toutes les modifications récentes :)
      _currentLocation = null;
    }
  }

<<<<<<< HEAD
  /// Create mock recommendations for testing
=======
  /// Données de recommandations mock
>>>>>>> 8579596d (Commit de toutes les modifications récentes :)
  List<RecommendationContentItem> _createMockRecommendations() {
    return [
      RecommendationContentItem(
        id: 'rec_1',
        title: 'Conseils d\'entretien automobile',
        description: 'Découvrez nos conseils pour maintenir votre véhicule en parfait état',
        imageUrl: 'https://example.com/car-maintenance.jpg',
        actionUrl: 'https://example.com/car-tips',
        metadata: {'category': 'automotive', 'priority': 'high'},
        timestamp: DateTime.now(),
      ),
      RecommendationContentItem(
        id: 'rec_2',
        title: 'Économisez sur vos factures d\'électricité',
        description: 'Astuces et conseils pour réduire votre consommation énergétique',
        imageUrl: 'https://example.com/energy-saving.jpg',
        actionUrl: 'https://example.com/energy-tips',
        metadata: {'category': 'energy', 'priority': 'medium'},
        timestamp: DateTime.now(),
      ),
    ];
  }

<<<<<<< HEAD
  /// Set loading state
=======
>>>>>>> 8579596d (Commit de toutes les modifications récentes :)
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

<<<<<<< HEAD
  /// Set error message
=======
>>>>>>> 8579596d (Commit de toutes les modifications récentes :)
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

<<<<<<< HEAD
  /// Clear error message
=======
>>>>>>> 8579596d (Commit de toutes les modifications récentes :)
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

<<<<<<< HEAD
  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
=======
  // Pas de ressources à libérer pour le moment
>>>>>>> 8579596d (Commit de toutes les modifications récentes :)
}