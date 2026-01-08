import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locacharge/features/user/models/advertisement_model.dart';
import 'package:locacharge/features/user/models/location_model.dart';
import 'package:locacharge/features/user/models/user_preferences_model.dart';

class AdvertisementService {
  static final AdvertisementService _instance = AdvertisementService._internal();
  factory AdvertisementService() => _instance;
  AdvertisementService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'advertisements';
  final String _analyticsCollectionName = 'advertisement_analytics';

  /// Fetch targeted advertisements based on user location and preferences
  Future<List<Advertisement>> fetchTargetedAds({
    required Location? userLocation,
    required double radiusKm,
    UserPreferences? userPreferences,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .orderBy('expiresAt')
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final QuerySnapshot snapshot = await query.get();
      List<Advertisement> ads = snapshot.docs
          .map((doc) => Advertisement.fromFirestore(doc))
          .toList();

      // Apply location-based filtering if user location is available
      if (userLocation != null) {
        ads = _filterByLocation(ads, userLocation, radiusKm);
      }

      // Apply user preferences filtering
      if (userPreferences != null) {
        ads = _filterByUserPreferences(ads, userPreferences);
      }

      return ads;
    } catch (e) {
      print('Error fetching targeted ads: $e');
      return [];
    }
  }

  /// Fetch general advertisements (fallback when location is unavailable)
  Future<List<Advertisement>> fetchGeneralAds({int? limit}) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .where('targetLocation', isNull: true) // General ads without location targeting
          .orderBy('expiresAt')
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Advertisement.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching general ads: $e');
      return [];
    }
  }

  /// Filter advertisements by location proximity
  List<Advertisement> _filterByLocation(
    List<Advertisement> ads,
    Location userLocation,
    double radiusKm,
  ) {
    return ads.where((ad) {
      if (ad.targetLocation == null) {
        return true; // Include general ads without location targeting
      }

      final adLocation = Location.fromGeoPoint(ad.targetLocation!);
      final distance = userLocation.distanceTo(adLocation);
      final adRadius = ad.targetRadiusKm ?? radiusKm;

      return distance <= adRadius;
    }).toList();
  }

  /// Filter advertisements by user preferences
  List<Advertisement> _filterByUserPreferences(
    List<Advertisement> ads,
    UserPreferences preferences,
  ) {
    return ads.where((ad) {
      // Filter out blocked merchants
      if (preferences.blockedMerchantIds.contains(ad.merchantId)) {
        return false;
      }

      // Filter by sponsored content preference
      if (!preferences.showSponsoredContent && 
          ad.type == AdvertisementType.sponsored) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Track advertisement impression
  Future<void> trackImpression(String adId, {String? userId}) async {
    try {
      await _firestore
          .collection(_analyticsCollectionName)
          .add({
        'adId': adId,
        'userId': userId,
        'type': 'impression',
        'timestamp': Timestamp.now(),
        'metadata': {},
      });
    } catch (e) {
      print('Error tracking impression: $e');
    }
  }

  /// Track advertisement click
  Future<void> trackClick(String adId, {String? userId}) async {
    try {
      await _firestore
          .collection(_analyticsCollectionName)
          .add({
        'adId': adId,
        'userId': userId,
        'type': 'click',
        'timestamp': Timestamp.now(),
        'metadata': {},
      });
    } catch (e) {
      print('Error tracking click: $e');
    }
  }

  /// Report an inappropriate advertisement
  Future<void> reportAd(String adId, String reason, {String? userId}) async {
    try {
      await _firestore
          .collection('advertisement_reports')
          .add({
        'adId': adId,
        'userId': userId,
        'reason': reason,
        'timestamp': Timestamp.now(),
        'status': 'pending', // pending, reviewed, resolved
      });
    } catch (e) {
      print('Error reporting ad: $e');
    }
  }

  /// Get targeting explanation for an advertisement
  String getTargetingExplanation(Advertisement ad) {
    List<String> reasons = [];

    if (ad.targetLocation != null) {
      reasons.add('Basée sur votre localisation');
    }

    if (ad.targetingCriteria.isNotEmpty) {
      if (ad.targetingCriteria.containsKey('categories')) {
        reasons.add('Basée sur vos préférences');
      }
      if (ad.targetingCriteria.containsKey('demographics')) {
        reasons.add('Basée sur votre profil');
      }
    }

    if (reasons.isEmpty) {
      return 'Publicité générale';
    }

    return reasons.join(', ');
  }

  /// Listen to real-time advertisement updates
  Stream<List<Advertisement>> listenToAdvertisements({
    Location? userLocation,
    double radiusKm = 10.0,
    int? limit,
  }) {
    Query query = _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      List<Advertisement> ads = snapshot.docs
          .map((doc) => Advertisement.fromFirestore(doc))
          .toList();

      // Apply location filtering if available
      if (userLocation != null) {
        ads = _filterByLocation(ads, userLocation, radiusKm);
      }

      return ads;
    });
  }

  /// Get advertisement by ID
  Future<Advertisement?> getAdvertisementById(String adId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_collectionName)
          .doc(adId)
          .get();

      if (doc.exists) {
        return Advertisement.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting advertisement by ID: $e');
      return null;
    }
  }

  /// Check if an advertisement is still active and valid
  bool isAdvertisementValid(Advertisement ad) {
    if (!ad.isActive) return false;
    if (ad.expiresAt != null && ad.expiresAt!.isBefore(DateTime.now())) {
      return false;
    }
    return true;
  }
}