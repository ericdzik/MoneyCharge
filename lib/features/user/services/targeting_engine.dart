import 'package:locacharge/features/user/models/advertisement_model.dart';
import 'package:locacharge/features/user/models/location_model.dart';
import 'package:locacharge/features/user/models/user_preferences_model.dart';

class TargetingEngine {
  static final TargetingEngine _instance = TargetingEngine._internal();
  factory TargetingEngine() => _instance;
  TargetingEngine._internal();

  /// Filter advertisements by proximity to user location
  List<Advertisement> filterByProximity({
    required List<Advertisement> ads,
    required Location userLocation,
    required double radiusKm,
  }) {
    return ads.where((ad) {
      // Include general ads without location targeting
      if (ad.targetLocation == null) {
        return true;
      }

      try {
        final adLocation = Location.fromGeoPoint(ad.targetLocation!);
        final distance = userLocation.distanceTo(adLocation);
        
        // Use ad-specific radius if available, otherwise use provided radius
        final effectiveRadius = ad.targetRadiusKm ?? radiusKm;
        
        return distance <= effectiveRadius;
      } catch (e) {
        print('Error calculating distance for ad ${ad.id}: $e');
        return false; // Exclude ads with invalid location data
      }
    }).toList();
  }

  /// Apply user preferences to filter advertisements
  List<Advertisement> applyUserPreferences({
    required List<Advertisement> ads,
    required UserPreferences preferences,
  }) {
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

      // Apply category preferences if specified
      if (preferences.preferredCategories.isNotEmpty) {
        final adCategories = ad.targetingCriteria['categories'] as List<dynamic>?;
        if (adCategories != null) {
          final hasPreferredCategory = adCategories.any(
            (category) => preferences.preferredCategories.contains(category.toString())
          );
          if (!hasPreferredCategory) {
            return false;
          }
        }
      }

      return true;
    }).toList();
  }

  /// Get fallback advertisements when location is unavailable
  List<Advertisement> getFallbackAds(List<Advertisement> allAds, int limit) {
    // Filter for general ads without location targeting
    final generalAds = allAds.where((ad) => 
      ad.targetLocation == null && 
      ad.isActive &&
      (ad.expiresAt == null || ad.expiresAt!.isAfter(DateTime.now()))
    ).toList();

    // Sort by creation date (newest first) and limit
    generalAds.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return generalAds.take(limit).toList();
  }

  /// Calculate relevance score for an advertisement
  double calculateRelevanceScore({
    required Advertisement ad,
    Location? userLocation,
    UserPreferences? preferences,
  }) {
    double score = 1.0; // Base score

    // Distance-based scoring (closer = higher score)
    if (userLocation != null && ad.targetLocation != null) {
      try {
        final adLocation = Location.fromGeoPoint(ad.targetLocation!);
        final distance = userLocation.distanceTo(adLocation);
        final maxRadius = ad.targetRadiusKm ?? 10.0;
        
        // Score decreases with distance (1.0 at 0km, 0.1 at max radius)
        final distanceScore = 1.0 - (distance / maxRadius * 0.9);
        score *= distanceScore.clamp(0.1, 1.0);
      } catch (e) {
        print('Error calculating distance score for ad ${ad.id}: $e');
      }
    }

    // Preference-based scoring
    if (preferences != null) {
      // Boost score for preferred categories
      final adCategories = ad.targetingCriteria['categories'] as List<dynamic>?;
      if (adCategories != null && preferences.preferredCategories.isNotEmpty) {
        final hasPreferredCategory = adCategories.any(
          (category) => preferences.preferredCategories.contains(category.toString())
        );
        if (hasPreferredCategory) {
          score *= 1.5; // 50% boost for preferred categories
        }
      }
    }

    // Recency scoring (newer ads get slight boost)
    final daysSinceCreation = DateTime.now().difference(ad.createdAt).inDays;
    final recencyScore = 1.0 + (7 - daysSinceCreation.clamp(0, 7)) * 0.05;
    score *= recencyScore;

    // Ad type scoring
    switch (ad.type) {
      case AdvertisementType.promotional:
        score *= 1.2; // Boost promotional ads
        break;
      case AdvertisementType.sponsored:
        score *= 1.1; // Slight boost for sponsored content
        break;
      default:
        break;
    }

    return score.clamp(0.0, 5.0); // Cap maximum score
  }

  /// Sort advertisements by relevance score
  List<Advertisement> sortByRelevance({
    required List<Advertisement> ads,
    Location? userLocation,
    UserPreferences? preferences,
  }) {
    // Calculate scores for all ads
    final adsWithScores = ads.map((ad) => {
      'ad': ad,
      'score': calculateRelevanceScore(
        ad: ad,
        userLocation: userLocation,
        preferences: preferences,
      ),
    }).toList();

    // Sort by score (highest first)
    adsWithScores.sort((a, b) => 
      (b['score'] as double).compareTo(a['score'] as double)
    );

    // Return sorted ads
    return adsWithScores.map((item) => item['ad'] as Advertisement).toList();
  }

  /// Apply comprehensive targeting (proximity + preferences + relevance)
  List<Advertisement> applyTargeting({
    required List<Advertisement> ads,
    Location? userLocation,
    double radiusKm = 10.0,
    UserPreferences? preferences,
    int? limit,
  }) {
    List<Advertisement> filteredAds = ads;

    // Apply proximity filtering if location is available
    if (userLocation != null) {
      filteredAds = filterByProximity(
        ads: filteredAds,
        userLocation: userLocation,
        radiusKm: radiusKm,
      );
    }

    // Apply user preferences
    if (preferences != null) {
      filteredAds = applyUserPreferences(
        ads: filteredAds,
        preferences: preferences,
      );
    }

    // Sort by relevance
    filteredAds = sortByRelevance(
      ads: filteredAds,
      userLocation: userLocation,
      preferences: preferences,
    );

    // Apply limit if specified
    if (limit != null && filteredAds.length > limit) {
      filteredAds = filteredAds.take(limit).toList();
    }

    return filteredAds;
  }

  /// Check if an advertisement should be shown to a user
  bool shouldShowAd({
    required Advertisement ad,
    Location? userLocation,
    UserPreferences? preferences,
    double radiusKm = 10.0,
  }) {
    // Check if ad is active and not expired
    if (!ad.isActive) return false;
    if (ad.expiresAt != null && ad.expiresAt!.isBefore(DateTime.now())) {
      return false;
    }

    // Check proximity if location is available
    if (userLocation != null && ad.targetLocation != null) {
      final adLocation = Location.fromGeoPoint(ad.targetLocation!);
      final distance = userLocation.distanceTo(adLocation);
      final effectiveRadius = ad.targetRadiusKm ?? radiusKm;
      
      if (distance > effectiveRadius) return false;
    }

    // Check user preferences
    if (preferences != null) {
      if (preferences.blockedMerchantIds.contains(ad.merchantId)) {
        return false;
      }
      
      if (!preferences.showSponsoredContent && 
          ad.type == AdvertisementType.sponsored) {
        return false;
      }
    }

    return true;
  }
}