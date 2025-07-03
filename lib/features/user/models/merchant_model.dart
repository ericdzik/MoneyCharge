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

  // Champs calculés côté client, ne pas stocker directement dans Firestore pour ce modèle
  double? clientCalculatedDistance;
  bool clientCalculatedIsOpen; // Basé sur 'hours' et l'heure actuelle
  MerchantStatus clientCalculatedStatus; // Pourrait être 'available' par défaut

  Merchant({
    required this.id,
    required this.name, // businessName depuis Firestore
    required this.address,
    required this.phone,
    required this.hours, // openingHours depuis Firestore
    required this.latitude,
    required this.longitude,
    required this.services,
    // Ces champs sont maintenant calculés ou ont des valeurs par défaut
    this.isOpen = false, // Sera calculé
    this.status = MerchantStatus.available, // Par défaut, ou à déterminer
    this.distance = 0.0, // Sera calculé
    this.walkingTime,
    this.drivingTime,
    // Initialisation des champs calculés par le client
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
      // Vous pourriez vouloir logger une erreur ici ou utiliser des valeurs par défaut plus significatives
      latitude = (data['latitude'] as num?)?.toDouble() ?? 0.0;
      longitude = (data['longitude'] as num?)?.toDouble() ?? 0.0;
    }

    // Les champs comme isOpen, status, distance, walkingTime, drivingTime
    // devront être calculés dynamiquement côté client.
    // Pour l'instant, on initialise avec des valeurs par défaut.
    return Merchant(
      id: userDoc.id, // UID de l'utilisateur/marchand
      name: data['name'] as String? ?? data['businessName'] as String? ?? 'Nom du Business Indisponible', // 'name' est le champ standard pour les marchands
      address: data['address'] as String? ?? 'Adresse Indisponible',
      phone: data['phone'] as String? ?? 'Téléphone Indisponible',
      hours: data['openingHours'] as String? ?? 'Horaires Indisponibles',
      latitude: latitude,
      longitude: longitude,
      services: List<String>.from(data['servicesOffered'] as List? ?? data['services'] as List? ?? []),
      // isOpen et status pourraient être initialisés à des valeurs par défaut ou déterminés plus tard
      isOpen: false, // À calculer dynamiquement
      status: MerchantStatus.available, // Par défaut, ou à déterminer par la logique de stock future
      // distance, walkingTime, drivingTime seront calculés par LocationProvider ou dans l'UI
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
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
    };
  }
}