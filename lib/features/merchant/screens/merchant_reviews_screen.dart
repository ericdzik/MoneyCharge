import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../models/review_model.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/constants/app_colors.dart';

class MerchantReviewsScreen extends StatelessWidget {
  final String merchantId;

  const MerchantReviewsScreen({super.key, required this.merchantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Avis des Clients',
        showLogo: false,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .where('merchantId', isEqualTo: merchantId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucun avis pour le moment.'));
          }

          final reviews = snapshot.data!.docs
              .map((doc) => Review.fromFirestore(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return ReviewTile(review: review);
            },
          );
        },
      ),
    );
  }
}

class ReviewTile extends StatelessWidget {
  final Review review;

  const ReviewTile({super.key, required this.review});

  // Helper widget to build the star rating
  Widget _buildRatingStars(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      Icon icon;
      if (i <= rating) {
        icon = const Icon(Icons.star, color: Colors.amber, size: 20.0);
      } else if (i > rating && i < rating + 1) {
        icon = const Icon(Icons.star_half, color: Colors.amber, size: 20.0);
      } else {
        icon = const Icon(Icons.star_border, color: Colors.amber, size: 20.0);
      }
      stars.add(icon);
    }
    return Row(children: stars);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: review.userProfileImageUrl != null
                      ? NetworkImage(review.userProfileImageUrl!)
                      : null,
                  child: review.userProfileImageUrl == null
                      ? Icon(Icons.person, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMMM yyyy, HH:mm').format(review.createdAt),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ),
                _buildRatingStars(review.rating),
              ],
            ),
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.comment!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
