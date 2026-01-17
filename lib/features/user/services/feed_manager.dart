
import 'package:geolocator/geolocator.dart';
import 'package:locacharge/features/user/models/merchant_model.dart';
import 'package:locacharge/models/ad_model.dart';
import 'package:locacharge/providers/ad_provider.dart';
import 'package:locacharge/providers/merchant_provider.dart';
import 'package:locacharge/services/location_service.dart';
import 'package:flutter/foundation.dart';

/// Types de contenu pour le fil
enum ContentItemType { advertisement, merchant, recommendation }

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
    _merchantProvider = merchantProvider;
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
      _setError('Erreur lors du chargement de contenu supplémentaire: ${e.toString()}');
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
      return [];
    }
  }

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
      return [];
    }
  }

  /// Charger des recommandations (mock pour l’instant)
  Future<List<RecommendationContentItem>> _loadRecommendations(int offset, int limit) async {
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
      content.add(AdvertisementContentItem(
        id: 'banner_${advertisements.first.id}',
        ad: advertisements.first,
        timestamp: DateTime.now(),
      ));
    }

    if (merchants.isNotEmpty) {
      content.addAll(merchants.take(10));
    }

    if (advertisements.length > 1) {
      for (int i = 1; i < advertisements.length; i++) {
        content.add(AdvertisementContentItem(
          id: 'sponsored_${advertisements[i].id}',
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
    List<MerchantContentItem> merchants,
    List<RecommendationContentItem> recommendations,
  ) {
    final List<ContentItem> content = [];
    final List<ContentItem> allContent = [];

    allContent.addAll(advertisements.map((ad) => AdvertisementContentItem(
      id: 'ad_${ad.id}',
      ad: ad,
      timestamp: DateTime.now(),
    )));
    allContent.addAll(merchants);
    allContent.addAll(recommendations);

    int adIndex = 0;
    for (int i = 0; i < allContent.length; i++) {
      content.add(allContent[i]);
      if ((i + 1) % 3 == 0 && adIndex < advertisements.length) {
        content.add(AdvertisementContentItem(
          id: 'mixed_ad_${advertisements[adIndex].id}',
          ad: advertisements[adIndex],
          timestamp: DateTime.now(),
        ));
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
      if (permissionStatus == LocationPermission.always || permissionStatus == LocationPermission.whileInUse) {
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