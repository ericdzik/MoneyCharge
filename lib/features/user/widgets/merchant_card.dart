import 'package:flutter/material.dart';
import 'package:locacharge/core/common.dart';

class MerchantCard extends StatelessWidget {
  final String merchantId;
  final String name;
  final List<String> services;
  final double? rating;
  final double? distanceKm;
  final String? imageUrl;
  final String? address;
  final bool isVerified;
  final VoidCallback onTap;

  const MerchantCard({
    Key? key,
    required this.merchantId,
    required this.name,
    required this.services,
    this.rating,
    this.distanceKm,
    this.imageUrl,
    this.address,
    this.isVerified = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            children: [
              _buildMerchantImage(),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: _buildMerchantInfo(),
              ),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMerchantImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        color: AppColors.gray200,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultImage();
                },
              )
            : _buildDefaultImage(),
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Icon(
        Icons.store,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  Widget _buildMerchantInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isVerified) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.verified,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        if (services.isNotEmpty) ...[
          Text(
            services.take(2).join(' • '),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            if (rating != null) ...[
              Icon(
                Icons.star,
                size: 14,
                color: Colors.amber,
              ),
              const SizedBox(width: 2),
              Text(
                rating!.toStringAsFixed(1),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (distanceKm != null) ...[
              Icon(
                Icons.location_on,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 2),
              Text(
                '${distanceKm!.toStringAsFixed(1)} km',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        if (address != null) ...[
          const SizedBox(height: 4),
          Text(
            address!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Icon(
        Icons.chevron_right,
        color: AppColors.primary,
        size: 20,
      ),
    );
  }
}