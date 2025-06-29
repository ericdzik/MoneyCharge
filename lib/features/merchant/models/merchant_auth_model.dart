import 'package:cloud_firestore/cloud_firestore.dart'; // Ajout de l'import

class MerchantAuthModel {
  final String id;
  final String email;
  final String businessName;
  final String phone;
  final String address;
  final String? openingHours;
  final String? services;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final double? latitude; // Added latitude
  final double? longitude; // Added longitude

  MerchantAuthModel({
    required this.id,
    required this.email,
    required this.businessName,
    required this.phone,
    required this.address,
    this.openingHours,
    this.services,
    this.isVerified = false,
    required this.createdAt,
    this.lastLoginAt,
    this.latitude, // Added to constructor
    this.longitude, // Added to constructor
  });

  // factory MerchantAuthModel.fromJson(Map<String, dynamic> json) {
  //   return MerchantAuthModel(
  //     id: json['id'] ?? '',
  //     email: json['email'] ?? '',
  //     businessName: json['businessName'] ?? '',
  //     phone: json['phone'] ?? '',
  //     address: json['address'] ?? '',
  //     openingHours: json['openingHours'],
  //     services: json['services'],
  //     isVerified: json['isVerified'] ?? false,
  //     createdAt: DateTime.parse(
  //       json['createdAt'] ?? DateTime.now().toIso8601String(),
  //     ),
  //     lastLoginAt: json['lastLoginAt'] != null
  //         ? DateTime.parse(json['lastLoginAt'])
  //         : null,
  //     latitude: (json['latitude'] as num?)?.toDouble(),
  //     longitude: (json['longitude'] as num?)?.toDouble(),
  //   );
  // }

  factory MerchantAuthModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return MerchantAuthModel(
      id: snapshot.id, // Utiliser l'ID du document (qui est l'UID)
      email: data['email'] as String? ?? '',
      businessName: data['name'] as String? ?? '', // Firestore 'name' field for businessName
      phone: data['phone'] as String? ?? '',
      address: data['address'] as String? ?? '',
      openingHours: data['openingHours'] as String?,
      services: data['services'] as String?,
      isVerified: data['isVerified'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      latitude: (data['latitude'] as num?)?.toDouble(), // Read latitude
      longitude: (data['longitude'] as num?)?.toDouble(), // Read longitude
    );
  }

  Map<String, dynamic> toJson() { // Or toFirestoreMap
    return {
      'id': id,
      'email': email,
      'businessName': businessName, // Should match Firestore field 'name' if that's the convention
      'phone': phone,
      'address': address,
      'openingHours': openingHours,
      'services': services,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt), // Use Timestamp for Firestore
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'latitude': latitude, // Add latitude
      'longitude': longitude, // Add longitude
    };
  }

  MerchantAuthModel copyWith({
    String? id,
    String? email,
    String? businessName,
    String? phone,
    String? address,
    String? openingHours,
    String? services,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    double? latitude, // Added to copyWith
    double? longitude, // Added to copyWith
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
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
