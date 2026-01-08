import 'package:flutter/foundation.dart';
import 'package:locacharge/features/user/models/content_item_model.dart';
import 'package:locacharge/features/user/models/advertisement_model.dart';
import 'package:locacharge/features/user/models/location_model.dart';
import 'package:locacharge/features/user/services/advertisement_service.dart';
import 'package:locacharge/features/user/services/geolocation_service.dart';
import 'package:locacharge/features/user/services/targeting_engine.dart';
import 'package:locacharge/features/user/services/merchant_service.dart';
import 'package:locacharge/providers/merchant_provider.dart';
import 'package:locacharge/models/ad_model.dart';
import 'package:locacharge/providers/ad_provider.dart';

class FeedManager extends ChangeNotifier {
  final AdvertisementService _advertisementService = AdvertisementService();
  final GeolocationService _geolocationService = GeolocationService();
  final TargetingEngine _targetingEngine = TargetingEngine();
  final MerchantService _merchantService = MerchantService();
  final AdProvider _adProvider = AdProvider();
  
  MerchantProvider? _merchantProvider;

  List<ContentItem> _contentItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  Location? _currentLocation;
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
    print('🔧 FeedManager: Initializing with MerchantProvider...');
    _merchantProvider = merchantProvider;
    _merchantService.initialize(merchantProvider);
    print('🔧 FeedManager: MerchantProvider initialized successfully');
  }

  /// Load initial content for the feed
  Future<void> loadInitialContent() async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();
    _currentPage = 0;
    _hasMoreContent = true;

    try {
      // Get current location with timeout to avoid blocking
      await _updateCurrentLocationWithTimeout();

      // Load initial content with optimized approach
      final content = await _loadContentPageOptimized(0);
      _contentItems = content;
      
      print('FeedManager: Loaded ${content.length} content items');
      print('FeedManager: Content types: ${content.map((c) => c.type.toString()).join(', ')}');
      
      if (content.length < _pageSize) {
        _hasMoreContent = false;
      }
    } catch (e) {
      print('FeedManager: Error loading initial content: $e');
      _setError('Erreur lors du chargement du contenu: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

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

  /// Refresh all content
  Future<void> refreshContent() async {
    await loadInitialContent();
  }

  /// Update user location and refresh content
  Future<void> updateLocation() async {
    try {
      // Vider le cache des marchands car la localisation change
      _merchantService.clearCache();
      
      await _updateCurrentLocation();
      await refreshContent();
    } catch (e) {
      _setError('Erreur lors de la mise à jour de la localisation: ${e.toString()}');
    }
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
      return [];
    }
  }

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
      return [];
    }
  }

  /// Load content recommendations
  Future<List<RecommendationContentItem>> _loadRecommendations(int offset, int limit) async {
    try {
      // This would typically call a recommendation service
      // For now, return mock data
      final mockRecommendations = _createMockRecommendations();
      return mockRecommendations.skip(offset).take(limit).toList();
    } catch (e) {
      print('Error loading recommendations: $e');
      return [];
    }
  }

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
    if (advertisements.length > 1) {
      for (int i = 1; i < advertisements.length; i++) {
        content.add(AdvertisementContentItem(
          id: 'sponsored_${advertisements[i].id}',
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
    List<MerchantContentItem> merchants,
    List<RecommendationContentItem> recommendations,
  ) {
    final List<ContentItem> content = [];
    final List<ContentItem> allContent = [];

    // Add all content to a single list
    allContent.addAll(advertisements.map((ad) => AdvertisementContentItem(
      id: 'ad_${ad.id}',
      advertisement: ad,
      timestamp: DateTime.now(),
    )));
    allContent.addAll(merchants);
    allContent.addAll(recommendations);

    // Mix content with advertisements every 3-4 items
    int adIndex = 0;
    for (int i = 0; i < allContent.length; i++) {
      content.add(allContent[i]);
      
      // Insert advertisement every 3-4 items
      if ((i + 1) % 3 == 0 && adIndex < advertisements.length) {
        content.add(AdvertisementContentItem(
          id: 'mixed_ad_${advertisements[adIndex].id}',
          advertisement: advertisements[adIndex],
          timestamp: DateTime.now(),
        ));
        adIndex++;
      }
    }

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
      _currentLocation = null;
    }
  }

  /// Create mock recommendations for testing
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

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}