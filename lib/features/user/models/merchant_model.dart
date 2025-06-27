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
  final String walkingTime;
  final String drivingTime;
  final List<String> services;

  Merchant({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.hours,
    required this.isOpen,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.walkingTime,
    required this.drivingTime,
    required this.services,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      hours: json['hours'],
      isOpen: json['isOpen'],
      status: MerchantStatus.values[json['status']],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      distance: json['distance'].toDouble(),
      walkingTime: json['walkingTime'],
      drivingTime: json['drivingTime'],
      services: List<String>.from(json['services']),
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