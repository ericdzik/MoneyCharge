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
  });

  factory MerchantAuthModel.fromJson(Map<String, dynamic> json) {
    return MerchantAuthModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      businessName: json['businessName'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      openingHours: json['openingHours'],
      services: json['services'],
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'businessName': businessName,
      'phone': phone,
      'address': address,
      'openingHours': openingHours,
      'services': services,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
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
    );
  }
}
