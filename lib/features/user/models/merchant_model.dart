import 'package:cloud_firestore/cloud_firestore.dart'; // Ajout de l'import pour GeoPoint et DocumentSnapshot

enum MerchantStatus { available, lowStock, outOfStock }

class Merchant {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String hours;
  final bool isOpen;
  final MerchantStatus status;
  final double latitude;
  final double longitude;
  final double distance;
  final String? walkingTime; // Sera calculé dynamiquement
  final String? drivingTime; // Sera calculé dynamiquement
  final List<String> services; // Champ 'servicesOffered' dans Firestore
  final String? merchantType; // Ajout du type de marchand
  final Map<String, String>? serviceStockStatus; // Ajout du statut du stock des services

  // Nouveaux champs pour correspondre à MerchantAuthModel et aux besoins de l'admin
  final String? email;
  final bool? isVerified;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  // Champs calculés côté client, ne pas stocker directement dans Firestore pour ce modèle
  double? clientCalculatedDistance;
  bool clientCalculatedIsOpen; // Basé sur 'hours' et l'heure actuelle
  MerchantStatus clientCalculatedStatus; // Pourrait être 'available' par défaut

  Merchant({
    required this.id,
    required this.name, // businessName depuis Firestore
    this.email, // Nouveau
    required this.address,
    required this.phone,
    required this.hours, // openingHours depuis Firestore
    required this.latitude,
    required this.longitude,
    required this.services,
    this.merchantType,
    this.serviceStockStatus,
    this.isVerified, // Nouveau
    this.createdAt, // Nouveau
    this.lastLoginAt, // Nouveau
    // Ces champs sont maintenant calculés ou ont des valeurs par défaut
    this.isOpen = false,
    this.status = MerchantStatus.available,
    this.distance = 0.0,
    this.walkingTime,
    this.drivingTime,
  }) : clientCalculatedIsOpen = false, clientCalculatedStatus = MerchantStatus.available;


  // L'ancienne factory fromJson peut être conservée si elle sert encore pour des données de test ou une API REST
  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Nom indisponible',
      address: json['address'] as String? ?? 'Adresse indisponible',
      phone: json['phone'] as String? ?? 'Téléphone indisponible',
      hours: json['hours'] as String? ?? 'Horaires indisponibles',
      isOpen: json['isOpen'] as bool? ?? false,
      status: json['status'] != null && json['status'] is int && json['status'] < MerchantStatus.values.length
          ? MerchantStatus.values[json['status'] as int]
          : MerchantStatus.available,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      walkingTime: json['walkingTime'] as String?,
      drivingTime: json['drivingTime'] as String?,
      services: List<String>.from(json['services'] as List? ?? []),
      merchantType: json['merchantType'] as String?,
      serviceStockStatus: json['serviceStockStatus'] != null
          ? Map<String, String>.from(json['serviceStockStatus'] as Map)
          : null,
    );
  }

  factory Merchant.fromFirestoreUserDoc(DocumentSnapshot<Map<String, dynamic>> userDoc) {
    final data = userDoc.data();
    if (data == null) {
      throw Exception("Document marchand vide pour l'UID: ${userDoc.id}");
    }

    // Extraction du GeoPoint et conversion
    double latitude = 0.0;
    double longitude = 0.0;
    final geoPoint = data['location'] as GeoPoint?; // Supposons que le champ GeoPoint s'appelle 'location'
    if (geoPoint != null) {
      latitude = geoPoint.latitude;
      longitude = geoPoint.longitude;
    } else {
      // Fallback si location n'est pas un GeoPoint ou est manquant
      latitude = (data['latitude'] as num?)?.toDouble() ?? 0.0;
      longitude = (data['longitude'] as num?)?.toDouble() ?? 0.0;
    }

    Map<String, String>? serviceStockStatusMap;
    if (data['serviceStockStatus'] != null && data['serviceStockStatus'] is Map) {
      serviceStockStatusMap = (data['serviceStockStatus'] as Map).map(
            (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }

    return Merchant(
      id: userDoc.id,
      name: data['name'] as String? ?? data['businessName'] as String? ?? 'Nom Indisponible',
      email: data['email'] as String?, // Lecture de l'email
      address: data['address'] as String? ?? 'Adresse Indisponible',
      phone: data['phone'] as String? ?? 'Téléphone Indisponible',
      hours: data['openingHours'] as String? ?? 'Horaires Indisponibles',
      latitude: latitude,
      longitude: longitude,
      services: List<String>.from(data['servicesOffered'] as List? ?? data['services'] as List? ?? []),
      merchantType: data['merchantType'] as String?,
      serviceStockStatus: serviceStockStatusMap,
      isVerified: data['isVerified'] as bool?, // Lecture de isVerified
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(), // Lecture de createdAt
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(), // Lecture de lastLoginAt
      isOpen: false,
      status: MerchantStatus.available,
    );
  }

  Map<String, dynamic> toJson() {
    // Note: This toJson might need updates if Merchant objects are ever written back to Firestore
    // with these new fields. For now, it's primarily for client-side use or other serializations.
    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
      'phone': phone,
      'hours': hours,
      'isOpen': isOpen,
      'status': status.index,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'walkingTime': walkingTime,
      'drivingTime': drivingTime,
      'services': services,
      'merchantType': merchantType,
      'serviceStockStatus': serviceStockStatus,
      'isVerified': isVerified,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }
}