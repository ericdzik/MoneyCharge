import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/constants/app_colors.dart';
import 'package:locacharge/core/constants/app_dimensions.dart';
import 'package:locacharge/core/constants/app_text_styles.dart';
import 'package:locacharge/models/review_model.dart';
import 'package:locacharge/core/utils/url_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MerchantReviewsScreen extends StatefulWidget {
  final String merchantId;

  const MerchantReviewsScreen({super.key, required this.merchantId});

  @override
  State<MerchantReviewsScreen> createState() => _MerchantReviewsScreenState();
}

class _MerchantReviewsScreenState extends State<MerchantReviewsScreen> {
  int? _filterStars; // null = tous, sinon 1..5
  String _sort = 'recent'; // 'recent' | 'top'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .where('merchantId', isEqualTo: widget.merchantId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final allReviews = snapshot.data?.docs
                  .map((doc) => Review.fromFirestore(doc))
                  .toList() ??
              [];

          // Stats
          final average = allReviews.isEmpty
              ? 0.0
              : allReviews.map((r) => r.rating).reduce((a, b) => a + b) /
                  allReviews.length;
          final dist = List<int>.filled(5, 0);
          for (final r in allReviews) {
            final bucket = r.rating.round().clamp(1, 5) - 1; // 0..4
            dist[bucket] += 1;
          }

          // Filtre + tri
          List<Review> reviews = List.of(allReviews);
          if (_filterStars != null) {
            reviews.retainWhere((r) => r.rating.round() == _filterStars);
          }
          if (_sort == 'top') {
            reviews.sort((a, b) {
              final byRating = b.rating.compareTo(a.rating);
              if (byRating != 0) return byRating;
              return b.createdAt.compareTo(a.createdAt);
            });
          } else {
            reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 140,
                elevation: 0,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('Avis des clients'),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Header résumé
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: _ReviewsHeader(
                    average: average,
                    total: allReviews.length,
                    distribution: dist,
                    filterStars: _filterStars,
                    onFilter: (v) => setState(() => _filterStars = v),
                    sort: _sort,
                    onSort: (v) => setState(() => _sort = v),
                  ),
                ),
              ),

              if (reviews.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text('Aucun avis pour le moment.'),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                        vertical: AppDimensions.paddingS,
                      ),
                      child: _ReviewCard(review: reviews[index]),
                    ),
                    childCount: reviews.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewsHeader extends StatelessWidget {
  final double average;
  final int total;
  final List<int> distribution; // index 0 -> 1★ ... index 4 -> 5★
  final int? filterStars;
  final ValueChanged<int?> onFilter;
  final String sort;
  final ValueChanged<String> onSort;

  const _ReviewsHeader({
    required this.average,
    required this.total,
    required this.distribution,
    required this.filterStars,
    required this.onFilter,
    required this.sort,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final maxCount = (distribution.isEmpty) ? 0 : distribution.reduce((a, b) => a > b ? a : b);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.reviews_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        average.toStringAsFixed(1),
                        style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 6),
                      _Stars(rating: average, size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('$total avis', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              const Spacer(),
              // Tri
              _ChoiceChip(
                label: 'Récents',
                selected: sort == 'recent',
                onTap: () => onSort('recent'),
              ),
              const SizedBox(width: 8),
              _ChoiceChip(
                label: 'Meilleures notes',
                selected: sort == 'top',
                onTap: () => onSort('top'),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          // Distribution
          for (int i = 4; i >= 0; i--) ...[
            _DistributionBar(
              stars: i + 1,
              count: distribution[i],
              max: maxCount,
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: AppDimensions.paddingM),
          // Filtres
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChoiceChip(
                label: 'Tous',
                selected: filterStars == null,
                onTap: () => onFilter(null),
              ),
              for (int s = 5; s >= 1; s--)
                _ChoiceChip(
                  label: '$s★ (${distribution[s - 1]})',
                  selected: filterStars == s,
                  onTap: () => onFilter(s),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DistributionBar extends StatelessWidget {
  final int stars;
  final int count;
  final int max;

  const _DistributionBar({
    required this.stars,
    required this.count,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = max == 0 ? 0 : count / max;
    return Row(
      children: [
        Text('$stars★', style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$count', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.primary.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: AppTextStyles.body2.copyWith(color: selected ? Colors.white : AppColors.primary),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: ClipOval(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: review.userProfileImageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: normalizeFirebaseStorageUrl(
                              review.userProfileImageUrl!,
                            ),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const SizedBox(),
                            errorWidget: (context, url, error) => Icon(
                              Icons.person,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: AppColors.primary,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            review.userName,
                            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _Stars(rating: review.rating, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(review.createdAt),
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              review.comment!,
              style: AppTextStyles.body2,
            ),
          ],
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final double rating;
  final double size;

  const _Stars({required this.rating, this.size = 18});

  @override
  Widget build(BuildContext context) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      if (rating >= i) {
        stars.add(Icon(Icons.star_rounded, color: Colors.amber, size: size));
      } else if (rating >= i - 0.5) {
        stars.add(Icon(Icons.star_half_rounded, color: Colors.amber, size: size));
      } else {
        stars.add(Icon(Icons.star_border_rounded, color: Colors.amber, size: size));
      }
    }
    return Row(children: stars);
  }
}
