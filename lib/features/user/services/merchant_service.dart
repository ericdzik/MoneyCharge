import 'dart:async';
import 'package:locacharge/features/user/models/content_item_model.dart';
import 'package:locacharge/features/user/models/location_model.dart';
import 'package:locacharge/features/user/services/geolocation_service.dart';
import 'package:locacharge/features/user/utils/merchant_distance_validator.dart';
import 'package:locacharge/providers/merchant_provider.dart';
import 'package:locacharge/features/user/models/merchant_model.dart';

class MerchantService {
  static final MerchantService _instance = MerchantService._internal();
  factory MerchantService() => _instance;
  MerchantService._internal();

  final GeolocationService _geolocationService = GeolocationService();
  MerchantProvider? _merchantProvider;
  
  // Cache pour éviter de recalculer les distances à chaque fois
  final Map<String, MerchantContentItem> _merchantCache = {};
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidityDuration = Duration(minutes: 5);

  /// Initialiser le service avec le MerchantProvider
  void initialize(MerchantProvider merchantProvider) {
    print('🔧 MerchantService: Initializing with MerchantProvider...');
    _merchantProvider = merchantProvider;
    print('🔧 MerchantService: MerchantProvider set successfully');
  }

  /// Recherche des marchands dans un rayon spécifique avec optimisation
  Future<List<MerchantContentItem>> findNearbyMerchants({
    required double radiusKm,
    Location? userLocation,
    int? limit,
    int offset = 0,
  }) async {
    print('🔍 MerchantService: findNearbyMerchants called with radius ${radiusKm}km');
    
    try {
      if (_merchantProvider == null) {
        print('❌ MerchantService: MerchantProvider is null');
        return [];
      }
      
      // Utiliser la localisation fournie ou obtenir la localisation actuelle
      Location? location = userLocation ?? await _geolocationService.getCurrentLocation();
      
      if (location == null) {
        print('🔍 MerchantService: No location, using default Paris location');
        // Utiliser une localisation par défaut pour la démo (Paris centre)
        location = Location(
          latitude: 48.8566,
          longitude: 2.3522,
          accuracy: 10,
          timestamp: DateTime.now(),
        );
      } else {
        print('🔍 MerchantService: Using location: ${location.latitude}, ${location.longitude}');
      }

      // Vérifier le cache
      if (_isCacheValid()) {
        print('🔍 MerchantService: Using cached results');
        return _getFromCache(radiusKm: radiusKm, limit: limit, offset: offset);
      }

      // Charger les vrais marchands depuis Firebase via MerchantProvider
      final realMerchants = await _loadRealMerchants();
      print('🔍 MerchantService: Loaded ${realMerchants.length} real merchants');
      
      // Calculer les distances et filtrer
      final merchantsWithDistance = await _calculateDistancesAndFilter(
        merchants: realMerchants,
        userLocation: location,
        radiusKm: radiusKm,
      );

      print('🔍 MerchantService: After filtering: ${merchantsWithDistance.length} merchants within ${radiusKm}km');

      // Mettre à jour le cache
      _updateCache(merchantsWithDistance);

      // Appliquer la pagination
      final result = merchantsWithDistance
          .skip(offset)
          .take(limit ?? merchantsWithDistance.length)
          .toList();

      print('🔍 MerchantService: Returning ${result.length} merchants');
      return result;
    } catch (e) {
      print('❌ MerchantService: Error: $e');
      return [];
    }
  }

  /// Recherche rapide des marchands dans un rayon de 3km (méthode optimisée)
  Future<List<MerchantContentItem>> findMerchantsWithin3Km({
    Location? userLocation,
    int? limit,
  }) async {
    return await findNearbyMerchants(
      radiusKm: 3.0,
      userLocation: userLocation,
      limit: limit,
    );
  }

  /// Charger les vrais marchands depuis Firebase via MerchantProvider
  Future<List<MerchantContentItem>> _loadRealMerchants() async {
    print('🔍 MerchantService: _loadRealMerchants called');
    
    if (_merchantProvider == null) {
      print('❌ MerchantService: MerchantProvider is null');
      return [];
    }

    try {
      print('🔍 MerchantService: Current merchants count: ${_merchantProvider!.merchants.length}');
      
      // S'assurer que les marchands sont chargés
      if (_merchantProvider!.merchants.isEmpty) {
        print('🔍 MerchantService: No merchants, calling listenToMerchants()');
        _merchantProvider!.listenToMerchants();
        
        // Attendre un peu plus longtemps pour que les données se chargent
        await Future.delayed(const Duration(seconds: 3));
        print('🔍 MerchantService: After delay, merchants count: ${_merchantProvider!.merchants.length}');
        
        // Si toujours vide, essayer une fois de plus
        if (_merchantProvider!.merchants.isEmpty) {
          print('🔍 MerchantService: Still no merchants, trying refresh');
          _merchantProvider!.refreshMerchants();
          await Future.delayed(const Duration(seconds: 2));
          print('🔍 MerchantService: After refresh, merchants count: ${_merchantProvider!.merchants.length}');
        }
      }

      final realMerchants = _merchantProvider!.merchants;
      print('🔍 MerchantService: Retrieved ${realMerchants.length} merchants from provider');

      // Convertir les Merchant en MerchantContentItem
      final merchantContentItems = realMerchants.map((merchant) {
        print('🔍 Converting merchant: ${merchant.name} (verified: ${merchant.isVerified})');
        return _convertMerchantToContentItem(merchant);
      }).toList();
      
      print('🔍 MerchantService: Converted ${merchantContentItems.length} merchants');
      return merchantContentItems;
    } catch (e) {
      print('❌ MerchantService: Error loading merchants: $e');
      return [];
    }
  }

  /// Convertir un Merchant en MerchantContentItem
  MerchantContentItem _convertMerchantToContentItem(Merchant merchant) {
    return MerchantContentItem(
      id: 'merchant_${merchant.id}',
      merchantId: merchant.id,
      name: merchant.name,
      services: merchant.services,
      rating: merchant.averageRating, // Utiliser averageRating au lieu de rating
      distanceKm: merchant.clientCalculatedDistance, // Peut être null
      imageUrl: merchant.imageUrls?.isNotEmpty == true ? merchant.imageUrls!.first : null, // Utiliser la première image
      address: merchant.address,
      isVerified: merchant.isVerified ?? false, // Gérer le cas null
      timestamp: DateTime.now(),
    );
  }

  /// Calculer les distances et filtrer les marchands
  Future<List<MerchantContentItem>> _calculateDistancesAndFilter({
    required List<MerchantContentItem> merchants,
    required Location userLocation,
    required double radiusKm,
  }) async {
    final List<MerchantContentItem> merchantsWithDistance = [];

    for (final merchant in merchants) {
      // Simuler des coordonnées pour les marchands (à remplacer par de vraies coordonnées)
      final merchantLocation = _getMerchantLocation(merchant);
      
      if (merchantLocation != null) {
        final distance = _geolocationService.calculateDistance(userLocation, merchantLocation);
        
        // Créer une nouvelle instance avec la distance calculée
        final merchantWithDistance = MerchantContentItem(
          id: merchant.id,
          merchantId: merchant.merchantId,
          name: merchant.name,
          services: merchant.services,
          rating: merchant.rating,
          distanceKm: distance,
          imageUrl: merchant.imageUrl,
          address: merchant.address,
          isVerified: merchant.isVerified,
          timestamp: merchant.timestamp,
        );

        merchantsWithDistance.add(merchantWithDistance);
      }
    }

    // Utiliser le validateur pour filtrer et trier
    final filteredMerchants = MerchantDistanceValidator.filterByRadius(merchantsWithDistance, radiusKm);
    final sortedMerchants = MerchantDistanceValidator.sortByDistance(filteredMerchants);

    return sortedMerchants;
  }

  /// Obtenir la localisation d'un marchand (utilise les vraies coordonnées du marchand)
  Location? _getMerchantLocation(MerchantContentItem merchant) {
    // Pour les vrais marchands, nous devons récupérer leurs coordonnées depuis le MerchantProvider
    if (_merchantProvider == null) return null;
    
    try {
      final realMerchant = _merchantProvider!.getMerchantById(merchant.merchantId);
      if (realMerchant != null) {
        return Location(
          latitude: realMerchant.latitude,
          longitude: realMerchant.longitude,
          accuracy: 10,
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      // Erreur silencieuse
    }
    
    return null;
  }

  /// Vérifier si le cache est valide
  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheValidityDuration;
  }

  /// Obtenir les données du cache
  List<MerchantContentItem> _getFromCache({
    required double radiusKm,
    int? limit,
    int offset = 0,
  }) {
    final allCachedMerchants = _merchantCache.values.toList();
    
    // Utiliser le validateur pour filtrer et trier
    final filteredMerchants = MerchantDistanceValidator.filterByRadius(allCachedMerchants, radiusKm);
    final sortedMerchants = MerchantDistanceValidator.sortByDistance(filteredMerchants);
    
    return sortedMerchants
        .skip(offset)
        .take(limit ?? sortedMerchants.length)
        .toList();
  }

  /// Mettre à jour le cache
  void _updateCache(List<MerchantContentItem> merchants) {
    _merchantCache.clear();
    for (final merchant in merchants) {
      _merchantCache[merchant.id] = merchant;
    }
    _lastCacheUpdate = DateTime.now();
  }

  /// Vider le cache (utile lors du changement de localisation)
  void clearCache() {
    _merchantCache.clear();
    _lastCacheUpdate = null;
  }

  /// Obtenir un marchand spécifique par ID
  Future<MerchantContentItem?> getMerchantById(String merchantId) async {
    // Vérifier d'abord le cache
    final cachedMerchant = _merchantCache.values
        .where((merchant) => merchant.merchantId == merchantId)
        .firstOrNull;
    
    if (cachedMerchant != null) {
      return cachedMerchant;
    }

    // Sinon, charger depuis le MerchantProvider
    final allMerchants = await _loadRealMerchants();
    return allMerchants
        .where((merchant) => merchant.merchantId == merchantId)
        .firstOrNull;
  }
}