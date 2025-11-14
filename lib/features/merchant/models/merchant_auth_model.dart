import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantAuthModel {
  final String id;
  final String email;
  final String businessName;
  final String phone;
  final String address;
  final Map<String, dynamic>? openingHours;
  final List<String>? services; // Modifié
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final double? latitude;
  final double? longitude;
  final String merchantType; // Ajouté
  final String? profileType;
  final Map<String, String>? serviceStockStatus; // Ajouté
  final List<String>? imageUrls;
  final String? profileImageUrl;
  final bool isSuspended;
  final double averageRating;
  final int reviewCount;
  final bool isPremium;

  MerchantAuthModel({
    required this.id,
    required this.email,
    required this.businessName,
    required this.phone,
    required this.address,
    this.openingHours,
    this.services, // Modifié
    this.isVerified = false,
    this.isSuspended = false,
    required this.createdAt,
    this.lastLoginAt,
    this.latitude,
    this.longitude,
    required this.merchantType, // Ajouté
    this.profileType,
    this.serviceStockStatus, // Ajouté
    this.imageUrls,
    this.profileImageUrl,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.isPremium = false,
  });

  factory MerchantAuthModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;

    Map<String, dynamic>? openingHoursData;
    final openingHoursField = data['openingHours'];
    if (openingHoursField is Map) {
      openingHoursData = openingHoursField as Map<String, dynamic>;
    }

    List<String>? servicesList;
    if (data['services'] != null) {
      if (data['services'] is String) {
        // Gérer le cas où c'est une chaîne (ancien format potentiel)
        // On pourrait la splitter par un délimiteur ou la mettre dans une liste d'un seul élément
        servicesList = [data['services'] as String];
      } else if (data['services'] is List) {
        servicesList = (data['services'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      }
    }

    Map<String, String>? stockStatus;
    if (data['serviceStockStatus'] != null && data['serviceStockStatus'] is Map) {
      stockStatus = (data['serviceStockStatus'] as Map).map((key, value) => MapEntry(key.toString(), value.toString()));
    }


    return MerchantAuthModel(
      id: snapshot.id,
      email: data['email'] as String? ?? '',
      businessName: data['name'] as String? ?? '', // Firestore 'name' field
      phone: data['phone'] as String? ?? '',
      address: data['address'] as String? ?? '',
      openingHours: openingHoursData,
      services: servicesList, // Modifié
      isVerified: data['isVerified'] as bool? ?? false,
      isSuspended: data['isSuspended'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      merchantType: data['merchantType'] as String? ?? 'boutique', // Ajouté avec défaut
      profileType: data['profileType'] as String?,
      serviceStockStatus: stockStatus, // Ajouté
      imageUrls: (data['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      profileImageUrl: data['profileImageUrl'] as String?,
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] as int? ?? 0,
      isPremium: data['isPremium'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      // Utiliser 'name' pour businessName si c'est la convention dans Firestore pour ce modèle
      'name': businessName,
      'phone': phone,
      'address': address,
      'openingHours': openingHours,
      'services': services, // Sera une liste
      'isVerified': isVerified,
      'isSuspended': isSuspended,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'latitude': latitude,
      'longitude': longitude,
      'merchantType': merchantType, // Ajouté
      'profileType': profileType,
      'serviceStockStatus': serviceStockStatus, // Ajouté
      'imageUrls': imageUrls,
      'profileImageUrl': profileImageUrl,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'isPremium': isPremium,
    };
  }

  MerchantAuthModel copyWith({
    String? id,
    String? email,
    String? businessName,
    String? phone,
    String? address,
    Map<String, dynamic>? openingHours,
    List<String>? services, // Modifié
    bool? isVerified,
    bool? isSuspended,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    double? latitude,
    double? longitude,
    String? merchantType, // Ajouté
    String? profileType,
    Map<String, String>? serviceStockStatus, // Ajouté
    List<String>? imageUrls,
    String? profileImageUrl,
    double? averageRating,
    int? reviewCount,
    bool? isPremium,
  }) {
    return MerchantAuthModel(
      id: id ?? this.id,
      email: email ?? this.email,
      businessName: businessName ?? this.businessName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      openingHours: openingHours ?? this.openingHours,
      services: services ?? this.services,
      isVerified: isVerified ?? this.isVerified,
      isSuspended: isSuspended ?? this.isSuspended,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      merchantType: merchantType ?? this.merchantType,
      profileType: profileType ?? this.profileType,
      serviceStockStatus: serviceStockStatus ?? this.serviceStockStatus,
      imageUrls: imageUrls ?? this.imageUrls,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
