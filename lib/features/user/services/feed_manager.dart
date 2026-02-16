import 'package:geolocator/geolocator.dart';
import 'package:locacharge/features/user/models/merchant_model.dart';
import 'package:locacharge/models/ad_model.dart';
import 'package:locacharge/providers/ad_provider.dart';
import 'package:locacharge/providers/merchant_provider.dart';
import 'package:locacharge/services/location_service.dart';
import 'package:locacharge/services/distance_matrix_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:locacharge/features/user/models/content_item_model.dart'
    show
        ContentItem,
        MerchantContentItem,
        AdvertisementContentItem,
        RecommendationContentItem;
import 'package:locacharge/features/user/models/advertisement_model.dart';

class FeedManager extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final DistanceMatrixService _distanceMatrixService =
      DistanceMatrixService();
  MerchantProvider? _merchantProvider;
  final AdProvider _adProvider = AdProvider();

  List<ContentItem> _contentItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  Position? _currentLocation;
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
    if (_merchantProvider != null) {
      _merchantProvider!.removeListener(_onMerchantProviderChange);
    }
    _merchantProvider = merchantProvider;
    _merchantProvider!.addListener(_onMerchantProviderChange);
  }

  @override
  void dispose() {
    _merchantProvider?.removeListener(_onMerchantProviderChange);
    super.dispose();
  }

  void _onMerchantProviderChange() {
    // Si le chargement initial a échoué à récupérer des marchands (race condition)
    // et que le provider en a maintenant, on recharge.
    if (!_isLoading && _merchantProvider != null) {
      final hasDisplayedMerchants = _contentItems.any(
        (item) => item is MerchantContentItem,
      );
      if (!hasDisplayedMerchants && _merchantProvider!.merchants.isNotEmpty) {
        // On ne recharge que si on est sur la première page pour éviter de perturber la pagination
        if (_currentPage == 0) {
          loadInitialContent();
        }
      }
    }
  }

  /// Charger le contenu initial du fil
  Future<void> loadInitialContent() async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();
    _currentPage = 0;
    _hasMoreContent = true;

    try {
      await _updateCurrentLocationWithTimeout();
      final content = await _loadContentPage(0);
      _contentItems = content;
      if (content.length < _pageSize) {
        _hasMoreContent = false;
      }
    } catch (e) {
      _setError('Erreur lors du chargement du contenu: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

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
        if (newContent.length < _pageSize) {
          _hasMoreContent = false;
        }
      } else {
        _hasMoreContent = false;
      }
    } catch (e) {
      _setError(
        'Erreur lors du chargement de contenu supplémentaire: ${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Rafraîchir tout le contenu
  Future<void> refreshContent() async {
    await loadInitialContent();
  }

  /// Tracking (placeholder)
  void trackAdvertisementClick(String advertisementId) {
    print('Advertisement clicked: $advertisementId');
  }

  void trackAdvertisementImpression(String advertisementId) {
    print('Advertisement impression: $advertisementId');
  }

  /// Charger une page spécifique de contenu
  Future<List<ContentItem>> _loadContentPage(int page) async {
    final List<ContentItem> pageContent = [];
    final offset = page * _pageSize;

    final advertisements = await _loadAdvertisements(offset, _pageSize ~/ 2);
    final merchants = await _loadNearbyMerchants(offset, _pageSize ~/ 3);
    final recommendations = await _loadRecommendations(offset, _pageSize ~/ 5);

    if (page == 0) {
      pageContent.addAll(
        _createStructuredFirstPage(advertisements, merchants, recommendations),
      );
    } else {
      pageContent.addAll(
        _createMixedContent(advertisements, merchants, recommendations),
      );
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
      return [];
    }
  }

  /// Charger des marchands proches (rayon 3 km)
  Future<List<MerchantContentItem>> _loadNearbyMerchants(
    int offset,
    int limit,
  ) async {
    try {
      final merchants = _merchantProvider?.merchants ?? [];
      List<Merchant> filtered = merchants;
      final Map<String, double?> distanceById = {};

      if (_currentLocation != null) {
        final location = _currentLocation!;

        // Pre-filter to reduce API load using straight-line distance
        filtered = merchants.where((m) {
          final hasValidCoords = !(m.latitude == 0.0 && m.longitude == 0.0);
          if (!hasValidCoords) {
            distanceById[m.id] = null;
            return true;
          }
          final distMeters = _locationService.calculateDistance(
            location.latitude,
            location.longitude,
            m.latitude,
            m.longitude,
          );
          return distMeters <= 5000; // prefilter within 5 km
        }).toList();

        if (filtered.isEmpty) {
          filtered = merchants;
        }

        // Real road distances with Distance Matrix (chunked)
        final origin = LatLng(location.latitude, location.longitude);
        final List<Merchant> withCoords = filtered
            .where((m) => !(m.latitude == 0.0 && m.longitude == 0.0))
            .toList();

        const int chunkSize = 25;
        for (int i = 0; i < withCoords.length; i += chunkSize) {
          final chunk = withCoords.skip(i).take(chunkSize).toList();
          final destinations = chunk
              .map((m) => LatLng(m.latitude, m.longitude))
              .toList();
          final distances = await _distanceMatrixService.getDrivingDistances(
            origin: origin,
            destinations: destinations,
          );
          for (int j = 0; j < chunk.length; j++) {
            final meters = j < distances.length ? distances[j] : null;
            distanceById[chunk[j].id] =
                meters != null ? (meters / 1000) : null;
          }
        }

        // Apply the actual distance filter (3 km) when available
        filtered = filtered.where((m) {
          final distKm = distanceById[m.id];
          if (distKm == null) return true;
          return distKm <= 3.0;
        }).toList();

        if (filtered.isEmpty) {
          filtered = merchants;
        }
      }

      final items = filtered
          .map(
            (m) => MerchantContentItem.fromMerchant(
              merchantId: m.id,
              name: m.name,
              services: m.services,
              rating: m.averageRating,
              distanceKm: distanceById[m.id],
              imageUrl: (m.imageUrls != null && m.imageUrls!.isNotEmpty)
                  ? m.imageUrls!.first
                  : null,
              address: m.address,
              isVerified: m.isVerified ?? false,
            ),
          )
          .toList();
      return items.skip(offset).take(limit).toList();
    } catch (_) {
      return [];
    }
  }

  /// Charger des recommandations (mock pour l’instant)
  Future<List<RecommendationContentItem>> _loadRecommendations(
    int offset,
    int limit,
  ) async {
    try {
      final mock = _createMockRecommendations();
      return mock.skip(offset).take(limit).toList();
    } catch (_) {
      return [];
    }
  }

  /// Contenu structuré pour la première page
  List<ContentItem> _createStructuredFirstPage(
    List<Ad> advertisements,
    List<MerchantContentItem> merchants,
    List<RecommendationContentItem> recommendations,
  ) {
    final List<ContentItem> content = [];

    if (advertisements.isNotEmpty) {
      content.add(
        AdvertisementContentItem(
          id: 'banner_${advertisements.first.id}',
          advertisement: Advertisement(
            id: advertisements.first.id,
            title: advertisements.first.title,
            description: advertisements.first.description,
            imageUrl: advertisements.first.imageUrl,
            merchantId: '',
            targetLocation: null,
            targetRadiusKm: null,
            type: AdvertisementType.banner,
            createdAt: advertisements.first.createdAt.toDate(),
            expiresAt: null,
            isActive: true,
            targetingCriteria: const {},
            callToAction: null,
          ),
          timestamp: DateTime.now(),
        ),
      );
    }

    if (merchants.isNotEmpty) {
      content.addAll(merchants.take(10));
    }

    if (advertisements.length > 1) {
      for (int i = 1; i < advertisements.length; i++) {
        content.add(
          AdvertisementContentItem(
            id: 'sponsored_${advertisements[i].id}',
            advertisement: Advertisement(
              id: advertisements[i].id,
              title: advertisements[i].title,
              description: advertisements[i].description,
              imageUrl: advertisements[i].imageUrl,
              merchantId: '',
              targetLocation: null,
              targetRadiusKm: null,
              type: AdvertisementType.banner,
              createdAt: advertisements[i].createdAt.toDate(),
              expiresAt: null,
              isActive: true,
              targetingCriteria: const {},
              callToAction: null,
            ),
            timestamp: DateTime.now(),
          ),
        );
      }
    }

    content.addAll(recommendations);
    return content;
  }

  /// Contenu mixte pour les pages suivantes
  List<ContentItem> _createMixedContent(
    List<Ad> advertisements,
    List<MerchantContentItem> merchants,
    List<RecommendationContentItem> recommendations,
  ) {
    final List<ContentItem> content = [];
    final List<ContentItem> allContent = [];

    allContent.addAll(
      advertisements.map(
        (ad) => AdvertisementContentItem(
          id: 'ad_${ad.id}',
          advertisement: Advertisement(
            id: ad.id,
            title: ad.title,
            description: ad.description,
            imageUrl: ad.imageUrl,
            merchantId: '',
            targetLocation: null,
            targetRadiusKm: null,
            type: AdvertisementType.banner,
            createdAt: ad.createdAt.toDate(),
            expiresAt: null,
            isActive: true,
            targetingCriteria: const {},
            callToAction: null,
          ),
          timestamp: DateTime.now(),
        ),
      ),
    );
    allContent.addAll(merchants);
    allContent.addAll(recommendations);

    int adIndex = 0;
    for (int i = 0; i < allContent.length; i++) {
      content.add(allContent[i]);
      if ((i + 1) % 3 == 0 && adIndex < advertisements.length) {
        final ad = advertisements[adIndex];
        content.add(
          AdvertisementContentItem(
            id: 'mixed_ad_${ad.id}',
            advertisement: Advertisement(
              id: ad.id,
              title: ad.title,
              description: ad.description,
              imageUrl: ad.imageUrl,
              merchantId: '',
              targetLocation: null,
              targetRadiusKm: null,
              type: AdvertisementType.banner,
              createdAt: ad.createdAt.toDate(),
              expiresAt: null,
              isActive: true,
              targetingCriteria: const {},
              callToAction: null,
            ),
            timestamp: DateTime.now(),
          ),
        );
        adIndex++;
      }
    }
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
      if (permissionStatus == LocationPermission.always ||
          permissionStatus == LocationPermission.whileInUse) {
        _currentLocation = await _locationService.getCurrentPosition();
      } else {
        _currentLocation = null;
      }
    } catch (_) {
      _currentLocation = null;
    }
  }

  /// Données de recommandations mock
  List<RecommendationContentItem> _createMockRecommendations() {
    return [
      RecommendationContentItem(
        id: 'rec_1',
        title: 'Conseils d\'entretien automobile',
        description:
            'Découvrez nos conseils pour maintenir votre véhicule en parfait état',
        imageUrl: 'https://example.com/car-maintenance.jpg',
        actionUrl: 'https://example.com/car-tips',
        metadata: {'category': 'automotive', 'priority': 'high'},
        timestamp: DateTime.now(),
      ),
      RecommendationContentItem(
        id: 'rec_2',
        title: 'Économisez sur vos factures d\'électricité',
        description:
            'Astuces et conseils pour réduire votre consommation énergétique',
        imageUrl: 'https://example.com/energy-saving.jpg',
        actionUrl: 'https://example.com/energy-tips',
        metadata: {'category': 'energy', 'priority': 'medium'},
        timestamp: DateTime.now(),
      ),
    ];
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
