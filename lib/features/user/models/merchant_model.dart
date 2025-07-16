import 'package:cloud_firestore/cloud_firestore.dart'; // Ajout de l'import pour GeoPoint et DocumentSnapshot
import '../../../core/utils/opening_hours_parser.dart'; // Nouvel import

enum MerchantStatus { available, lowStock, outOfStock }

class Merchant {
  final String id;
  final String name;
  final String address;
  final String phone;
  final Map<String, dynamic>? hours;
  final String? profileType;
  // final bool isOpen; // Supprimé pour éviter conflit et erreur d'initialisation
  final MerchantStatus status;
  final double latitude;
  final double longitude;
  final double distance;
  final String? walkingTime; // Sera calculé dynamiquement
  final String? drivingTime; // Sera calculé dynamiquement
  final List<String> services; // Champ 'servicesOffered' dans Firestore
  final String? merchantType; // Ajout du type de marchand
  final Map<String, String>? serviceStockStatus; // Ajout du statut du stock des services
  final List<String>? imageUrls;

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
    this.hours, // openingHours depuis Firestore
    this.profileType,
    required this.latitude,
    required this.longitude,
    required this.services,
    this.merchantType,
    this.serviceStockStatus,
    this.imageUrls,
    this.isVerified, // Nouveau
    this.createdAt, // Nouveau
    this.lastLoginAt, // Nouveau
    // Ces champs sont maintenant calculés ou ont des valeurs par défaut
    // this.isOpen = false, // Sera calculé
    this.status = MerchantStatus.available,
    this.distance = 0.0,
    this.walkingTime,
    this.drivingTime,
  }) : clientCalculatedIsOpen = false, clientCalculatedStatus = MerchantStatus.available {
     _updateOpenStatusBasedOnHours();
  }


  // L'ancienne factory fromJson peut être conservée si elle sert encore pour des données de test ou une API REST
  factory Merchant.fromJson(Map<String, dynamic> json) {
    Merchant merchant = Merchant(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Nom indisponible',
      address: json['address'] as String? ?? 'Adresse indisponible',
      phone: json['phone'] as String? ?? 'Téléphone indisponible',
      hours: json['hours'] as Map<String, dynamic>?,
      profileType: json['profileType'] as String?,
      // isOpen: json['isOpen'] as bool? ?? false, // Sera calculé
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
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
      // Les champs comme email, isVerified, createdAt, lastLoginAt devraient aussi être lus ici si présents dans le JSON
      email: json['email'] as String?,
      isVerified: json['isVerified'] as bool?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.tryParse(json['lastLoginAt'] as String) : null,
    );
    // Note: _updateOpenStatusBasedOnHours() est déjà appelé par le constructeur principal de Merchant
    // donc pas besoin de le rappeler ici si Merchant() est bien le constructeur utilisé.
    // Si le constructeur par défaut n'est pas appelé explicitement (ce qui est le cas ici car on a Merchant(...)),
    // alors il faut appeler _updateOpenStatusBasedOnHours() manuellement ou s'assurer que le constructeur principal le fait.
    // Le constructeur principal a été modifié pour appeler _updateOpenStatusBasedOnHours(), donc c'est bon.
    return merchant;
  }

  factory Merchant.fromFirestoreUserDoc(DocumentSnapshot<Map<String, dynamic>> userDoc) {
    final data = userDoc.data();
    if (data == null) {
      throw Exception("Document marchand vide pour l'UID: ${userDoc.id}");
    }

    // Extraction du GeoPoint et conversion
    double latitude = 0.0;
    double longitude = 0.0;
    final geoPoint = data['location'] as GeoPoint?;
    if (geoPoint != null) {
      latitude = geoPoint.latitude;
      longitude = geoPoint.longitude;
    } else {
      latitude = (data['latitude'] as num?)?.toDouble() ?? 0.0;
      longitude = (data['longitude'] as num?)?.toDouble() ?? 0.0;
    }

    Map<String, String>? serviceStockStatusMap;
    if (data['serviceStockStatus'] != null && data['serviceStockStatus'] is Map) {
      serviceStockStatusMap = (data['serviceStockStatus'] as Map).map(
            (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }

    Merchant merchant = Merchant(
      id: userDoc.id,
      name: data['name'] as String? ?? data['businessName'] as String? ?? 'Nom Indisponible',
      email: data['email'] as String?,
      address: data['address'] as String? ?? 'Adresse Indisponible',
      phone: data['phone'] as String? ?? 'Téléphone Indisponible',
      hours: data['openingHours'] as Map<String, dynamic>?,
      profileType: data['profileType'] as String?,
      latitude: latitude,
      longitude: longitude,
      services: List<String>.from(data['servicesOffered'] as List? ?? data['services'] as List? ?? []),
      merchantType: data['merchantType'] as String?,
      serviceStockStatus: serviceStockStatusMap,
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? []),
      isVerified: data['isVerified'] as bool?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      // isOpen: false, // Sera calculé par _updateOpenStatusBasedOnHours via le constructeur
      // status: MerchantStatus.available, // Déjà géré par le constructeur principal
    );
    // _updateOpenStatusBasedOnHours() est appelé par le constructeur principal
    return merchant;
  }

  void _updateOpenStatusBasedOnHours() {
    clientCalculatedIsOpen = OpeningHoursParser.isStoreOpenFromMap(hours, DateTime.now());
  }

  // Assurer que le getter `isOpen` utilise la valeur calculée.
  bool get isOpen => clientCalculatedIsOpen;
  // La variable d'instance `isOpen` n'est plus directement utilisée pour stocker l'état.

  Map<String, dynamic> toJson() {
    // Note: This toJson might need updates if Merchant objects are ever written back to Firestore
    // with these new fields. For now, it's primarily for client-side use or other serializations.
    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
      'phone': phone,
      'hours': hours, // C'est déjà une Map
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
      'imageUrls': imageUrls,
      'isVerified': isVerified,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }
}