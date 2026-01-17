import 'package:flutter/material.dart';
import 'package:locacharge/core/common.dart';
import 'package:locacharge/features/user/models/content_item_model.dart';
import 'package:locacharge/features/user/widgets/advertisement_card.dart';
import 'package:locacharge/features/user/widgets/merchant_card.dart';

class ContentFeedComponent extends StatefulWidget {
  final List<ContentItem> items;
  final Future<void> Function()? onRefresh;
  final Function(ContentItem) onItemTap;
  final ScrollController? scrollController;
  final bool isLoading;
  final String? errorMessage;

  const ContentFeedComponent({
    Key? key,
    required this.items,
    this.onRefresh,
    required this.onItemTap,
    this.scrollController,
    this.isLoading = false,
    this.errorMessage,
  }) : super(key: key);

  @override
  State<ContentFeedComponent> createState() => _ContentFeedComponentState();
}

class _ContentFeedComponentState extends State<ContentFeedComponent> {
  late ScrollController _scrollController;
  final Set<String> _viewedItems = <String>{};

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    // Track viewed items for analytics
    // This could be enhanced to track impression time
  }

  @override
  Widget build(BuildContext context) {
    if (widget.errorMessage != null) {
      return _buildErrorState();
    }

    if (widget.isLoading && widget.items.isEmpty) {
      return _buildLoadingState();
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh ?? () async {},
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.items.length + (widget.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= widget.items.length) {
            return widget.isLoading ? _buildLoadingItem() : const SizedBox.shrink();
          }

          final item = widget.items[index];
          return _buildContentItem(item, index);
        },
      ),
    );
  }

  Widget _buildContentItem(ContentItem item, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      child: _buildItemByType(item),
    );
  }

  Widget _buildItemByType(ContentItem item) {
    switch (item.type) {
      case ContentType.advertisement:
        final adItem = item as AdvertisementContentItem;
        return AdvertisementCard(
          advertisement: adItem.advertisement,
          onTap: () => widget.onItemTap(item),
          onImpression: () => _trackImpression(item.id),
        );

      case ContentType.merchant:
        final merchantItem = item as MerchantContentItem;
        return MerchantCard(
          merchantId: merchantItem.merchantId,
          name: merchantItem.name,
          services: merchantItem.services,
          rating: merchantItem.rating,
          distanceKm: merchantItem.distanceKm,
          imageUrl: merchantItem.imageUrl,
          address: merchantItem.address,
          isVerified: merchantItem.isVerified,
          onTap: () => widget.onItemTap(item),
        );

      case ContentType.section:
        final sectionItem = item as SectionContentItem;
        return _buildSectionItem(sectionItem);

      case ContentType.recommendation:
        final recommendationItem = item as RecommendationContentItem;
        return _buildRecommendationItem(recommendationItem);
    }
  }

  Widget _buildSectionItem(SectionContentItem section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: AppTextStyles.h2.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (section.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  section.subtitle!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        ...section.items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
          child: _buildItemByType(item),
        )),
      ],
    );
  }

  Widget _buildRecommendationItem(RecommendationContentItem recommendation) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: InkWell(
        onTap: () => widget.onItemTap(recommendation),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                child: Image.network(
                  recommendation.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: AppColors.gray200,
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title,
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recommendation.description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingXL),
        child: LoadingIndicator(),
      ),
    );
  }

  Widget _buildLoadingItem() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      child: Card(
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 200,
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 150,
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              widget.errorMessage!,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingL),
            ElevatedButton(
              onPressed: widget.onRefresh,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  void _trackImpression(String itemId) {
    if (!_viewedItems.contains(itemId)) {
      _viewedItems.add(itemId);
      // Here you would typically call an analytics service
      print('Tracking impression for item: $itemId');
    }
  }
}