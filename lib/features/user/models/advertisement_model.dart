import 'package:cloud_firestore/cloud_firestore.dart';

enum AdvertisementType {
  banner,
  card,
  promotional,
  sponsored
}

class Advertisement {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String merchantId;
  final GeoPoint? targetLocation;
  final double? targetRadiusKm;
  final AdvertisementType type;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;
  final Map<String, dynamic> targetingCriteria;
  final String? callToAction;

  const Advertisement({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.merchantId,
    this.targetLocation,
    this.targetRadiusKm,
    required this.type,
    required this.createdAt,
    this.expiresAt,
    required this.isActive,
    required this.targetingCriteria,
    this.callToAction,
  });

  factory Advertisement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Advertisement(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      merchantId: data['merchantId'] ?? '',
      targetLocation: data['targetLocation'] as GeoPoint?,
      targetRadiusKm: data['targetRadiusKm']?.toDouble(),
      type: AdvertisementType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => AdvertisementType.banner,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: data['expiresAt'] != null 
          ? (data['expiresAt'] as Timestamp).toDate() 
          : null,
      isActive: data['isActive'] ?? false,
      targetingCriteria: Map<String, dynamic>.from(data['targetingCriteria'] ?? {}),
      callToAction: data['callToAction'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'merchantId': merchantId,
      'targetLocation': targetLocation,
      'targetRadiusKm': targetRadiusKm,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'isActive': isActive,
      'targetingCriteria': targetingCriteria,
      'callToAction': callToAction,
    };
  }

  Advertisement copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? merchantId,
    GeoPoint? targetLocation,
    double? targetRadiusKm,
    AdvertisementType? type,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isActive,
    Map<String, dynamic>? targetingCriteria,
    String? callToAction,
  }) {
    return Advertisement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      merchantId: merchantId ?? this.merchantId,
      targetLocation: targetLocation ?? this.targetLocation,
      targetRadiusKm: targetRadiusKm ?? this.targetRadiusKm,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      targetingCriteria: targetingCriteria ?? this.targetingCriteria,
      callToAction: callToAction ?? this.callToAction,
    );
  }
}