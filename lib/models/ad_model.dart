import 'package:cloud_firestore/cloud_firestore.dart';

class Ad {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String url;
  final Timestamp createdAt;

  Ad({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.url,
    required this.createdAt,
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
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'url': url,
      'createdAt': createdAt,
    };
  }
}
