import 'package:cloud_firestore/cloud_firestore.dart';

class Ad {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String url;
  final Timestamp createdAt;
  final String? merchantId;
  final bool isActive;
  final Timestamp? expiresAt;

  Ad({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.url,
    required this.createdAt,
    this.merchantId,
    this.isActive = true,
    this.expiresAt,
  });

  factory Ad.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Ad(
      id: snapshot.id,
      title: data['title'] as String,
      description: data['description'] as String,
      imageUrl: data['imageUrl'] as String,
      url: data['url'] as String,
      createdAt: data['createdAt'] as Timestamp,
      merchantId: data['merchantId'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      expiresAt: data['expiresAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'url': url,
      'createdAt': createdAt,
      'merchantId': merchantId,
      'isActive': isActive,
      'expiresAt': expiresAt,
    };
  }
}
