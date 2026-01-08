import 'package:locacharge/features/user/models/advertisement_model.dart';

enum ContentType {
  advertisement,
  merchant,
  recommendation,
  section
}

abstract class ContentItem {
  final String id;
  final ContentType type;
  final DateTime timestamp;

  const ContentItem({
    required this.id,
    required this.type,
    required this.timestamp,
  });
}

class MerchantContentItem extends ContentItem {
  final String merchantId;
  final String name;
  final List<String> services;
  final double rating;
  final double? distanceKm; // Permettre null pour les distances non calculées
  final String? imageUrl;
  final String address;
  final bool isVerified;

  const MerchantContentItem({
    required String id,
    required this.merchantId,
    required this.name,
    required this.services,
    required this.rating,
    this.distanceKm, // Optionnel maintenant
    this.imageUrl,
    required this.address,
    required this.isVerified,
    required DateTime timestamp,
  }) : super(id: id, type: ContentType.merchant, timestamp: timestamp);

  factory MerchantContentItem.fromMerchant({
    required String merchantId,
    required String name,
    required List<String> services,
    required double rating,
    double? distanceKm, // Optionnel
    String? imageUrl,
    required String address,
    required bool isVerified,
  }) {
    return MerchantContentItem(
      id: 'merchant_$merchantId',
      merchantId: merchantId,
      name: name,
      services: services,
      rating: rating,
      distanceKm: distanceKm,
      imageUrl: imageUrl,
      address: address,
      isVerified: isVerified,
      timestamp: DateTime.now(),
    );
  }
}

class AdvertisementContentItem extends ContentItem {
  final Advertisement advertisement;

  const AdvertisementContentItem({
    required String id,
    required this.advertisement,
    required DateTime timestamp,
  }) : super(id: id, type: ContentType.advertisement, timestamp: timestamp);

  factory AdvertisementContentItem.fromAdvertisement(Advertisement ad) {
    return AdvertisementContentItem(
      id: 'ad_${ad.id}',
      advertisement: ad,
      timestamp: DateTime.now(),
    );
  }
}

class SectionContentItem extends ContentItem {
  final String title;
  final String? subtitle;
  final List<ContentItem> items;

  const SectionContentItem({
    required String id,
    required this.title,
    this.subtitle,
    required this.items,
    required DateTime timestamp,
  }) : super(id: id, type: ContentType.section, timestamp: timestamp);

  factory SectionContentItem.nearbyMerchants(List<MerchantContentItem> merchants) {
    return SectionContentItem(
      id: 'section_nearby_merchants',
      title: 'Marchands à proximité',
      subtitle: '${merchants.length} marchands trouvés',
      items: merchants,
      timestamp: DateTime.now(),
    );
  }
}

class RecommendationContentItem extends ContentItem {
  final String title;
  final String description;
  final String imageUrl;
  final String? actionUrl;
  final Map<String, dynamic> metadata;

  const RecommendationContentItem({
    required String id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.actionUrl,
    required this.metadata,
    required DateTime timestamp,
  }) : super(id: id, type: ContentType.recommendation, timestamp: timestamp);
}