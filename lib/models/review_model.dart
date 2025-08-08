import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String merchantId;
  final String userId;
  final String userName;
  final String? userProfileImageUrl;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.merchantId,
    required this.userId,
    required this.userName,
    this.userProfileImageUrl,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception("Review document data is null!");
    }

    return Review(
      id: snapshot.id,
      merchantId: data['merchantId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Utilisateur anonyme',
      userProfileImageUrl: data['userProfileImageUrl'] as String?,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchantId': merchantId,
      'userId': userId,
      'userName': userName,
      'userProfileImageUrl': userProfileImageUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
