import 'package:cloud_firestore/cloud_firestore.dart';

class CustomServiceModel {
  final String id;
  final String merchantId;
  final String name;
  final String description;
  final double defaultPrice;
  final String category;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CustomServiceModel({
    required this.id,
    required this.merchantId,
    required this.name,
    required this.description,
    required this.defaultPrice,
    required this.category,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory CustomServiceModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    return CustomServiceModel(
      id: doc.id,
      merchantId: data['merchantId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      defaultPrice: (data['defaultPrice'] ?? 0).toDouble(),
      category: data['category'] ?? 'Autre',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'merchantId': merchantId,
      'name': name,
      'description': description,
      'defaultPrice': defaultPrice,
      'category': category,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  CustomServiceModel copyWith({
    String? id,
    String? merchantId,
    String? name,
    String? description,
    double? defaultPrice,
    String? category,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomServiceModel(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      name: name ?? this.name,
      description: description ?? this.description,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}