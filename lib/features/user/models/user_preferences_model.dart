enum AdvertisementFrequency {
  low,    // Every 6-8 items
  medium, // Every 4-5 items
  high    // Every 2-3 items
}

class UserPreferences {
  final String userId;
  final bool locationTrackingEnabled;
  final AdvertisementFrequency adFrequency;
  final List<String> blockedMerchantIds;
  final List<String> preferredCategories;
  final bool analyticsEnabled;
  final double maxAdvertisementRadius;
  final bool showSponsoredContent;

  const UserPreferences({
    required this.userId,
    required this.locationTrackingEnabled,
    required this.adFrequency,
    required this.blockedMerchantIds,
    required this.preferredCategories,
    required this.analyticsEnabled,
    this.maxAdvertisementRadius = 10.0, // Default 10km
    this.showSponsoredContent = true,
  });

  /// Get the number of items between advertisements based on frequency setting
  int get itemsBetweenAds {
    switch (adFrequency) {
      case AdvertisementFrequency.low:
        return 7; // Every 7 items
      case AdvertisementFrequency.medium:
        return 4; // Every 4 items
      case AdvertisementFrequency.high:
        return 2; // Every 2 items
    }
  }

  factory UserPreferences.defaultPreferences(String userId) {
    return UserPreferences(
      userId: userId,
      locationTrackingEnabled: true,
      adFrequency: AdvertisementFrequency.medium,
      blockedMerchantIds: [],
      preferredCategories: [],
      analyticsEnabled: true,
      maxAdvertisementRadius: 10.0,
      showSponsoredContent: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'locationTrackingEnabled': locationTrackingEnabled,
      'adFrequency': adFrequency.name,
      'blockedMerchantIds': blockedMerchantIds,
      'preferredCategories': preferredCategories,
      'analyticsEnabled': analyticsEnabled,
      'maxAdvertisementRadius': maxAdvertisementRadius,
      'showSponsoredContent': showSponsoredContent,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      userId: map['userId'] ?? '',
      locationTrackingEnabled: map['locationTrackingEnabled'] ?? true,
      adFrequency: AdvertisementFrequency.values.firstWhere(
        (e) => e.name == map['adFrequency'],
        orElse: () => AdvertisementFrequency.medium,
      ),
      blockedMerchantIds: List<String>.from(map['blockedMerchantIds'] ?? []),
      preferredCategories: List<String>.from(map['preferredCategories'] ?? []),
      analyticsEnabled: map['analyticsEnabled'] ?? true,
      maxAdvertisementRadius: map['maxAdvertisementRadius']?.toDouble() ?? 10.0,
      showSponsoredContent: map['showSponsoredContent'] ?? true,
    );
  }

  UserPreferences copyWith({
    String? userId,
    bool? locationTrackingEnabled,
    AdvertisementFrequency? adFrequency,
    List<String>? blockedMerchantIds,
    List<String>? preferredCategories,
    bool? analyticsEnabled,
    double? maxAdvertisementRadius,
    bool? showSponsoredContent,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      locationTrackingEnabled: locationTrackingEnabled ?? this.locationTrackingEnabled,
      adFrequency: adFrequency ?? this.adFrequency,
      blockedMerchantIds: blockedMerchantIds ?? this.blockedMerchantIds,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      maxAdvertisementRadius: maxAdvertisementRadius ?? this.maxAdvertisementRadius,
      showSponsoredContent: showSponsoredContent ?? this.showSponsoredContent,
    );
  }
}