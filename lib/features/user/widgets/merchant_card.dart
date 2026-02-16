import 'package:flutter/material.dart';
import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/widgets/cached_image.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image du marchand
                Hero(
                  tag: 'merchant_img_$merchantId',
                  child: _buildMerchantImage(),
                ),
                const SizedBox(width: 16),

                // Informations
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre et Badge Vérifié
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: AppTextStyles.h3.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ],
                        ],
                      ),

                      // Adresse
                      if (address != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                address!,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Services (Tags)
                      if (services.isNotEmpty)
                        SizedBox(
                          height: 24,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: services.take(3).length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 6),
                            itemBuilder: (context, index) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors
                                        .border, // Utilisation de AppColors.border
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  services[index],
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 10),

                      // Métriques (Note et Distance)
                      Row(
                        children: [
                          // Note
                          if (rating != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    rating!.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Colors.amber, // Text color dark amber
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const Spacer(),

                          // Distance
                          if (distanceKm != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.directions_walk,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${distanceKm!.toStringAsFixed(1)} km',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMerchantImage() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.gray200,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageUrl != null
            ? CachedImage(imageUrl: imageUrl!, fit: BoxFit.cover)
            : _buildDefaultImage(),
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Center(
        child: Icon(
          Icons.store_rounded,
          color: AppColors.primary.withValues(alpha: 0.5),
          size: 32,
        ),
      ),
    );
  }
}
