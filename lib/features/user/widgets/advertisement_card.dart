import 'package:flutter/material.dart';
import 'package:locacharge/core/common.dart';
import 'package:locacharge/features/user/models/advertisement_model.dart';

class AdvertisementCard extends StatefulWidget {
  final Advertisement advertisement;
  final VoidCallback onTap;
  final VoidCallback? onImpression;
  final VoidCallback? onReport;

  const AdvertisementCard({
    Key? key,
    required this.advertisement,
    required this.onTap,
    this.onImpression,
    this.onReport,
  }) : super(key: key);

  @override
  State<AdvertisementCard> createState() => _AdvertisementCardState();
}

class _AdvertisementCardState extends State<AdvertisementCard> {
  bool _hasTrackedImpression = false;

  @override
  void initState() {
    super.initState();
    // Track impression when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackImpression();
    });
  }

  void _trackImpression() {
    if (!_hasTrackedImpression && widget.onImpression != null) {
      widget.onImpression!();
      _hasTrackedImpression = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAdImage(),
            _buildAdContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppDimensions.radiusM),
            topRight: Radius.circular(AppDimensions.radiusM),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9, // Standard banner aspect ratio
            child: Image.network(
              widget.advertisement.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppColors.gray200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.gray200,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Sponsored indicator
        Positioned(
          top: AppDimensions.paddingS,
          left: AppDimensions.paddingS,
          child: _buildSponsoredBadge(),
        ),
        // More options button
        Positioned(
          top: AppDimensions.paddingS,
          right: AppDimensions.paddingS,
          child: _buildMoreOptionsButton(),
        ),
      ],
    );
  }

  Widget _buildSponsoredBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Text(
        'Sponsorisé',
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMoreOptionsButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.more_vert,
          color: Colors.white,
          size: 18,
        ),
        onPressed: _showMoreOptions,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
      ),
    );
  }

  Widget _buildAdContent() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.advertisement.title,
            style: AppTextStyles.h3.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            widget.advertisement.description,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.advertisement.callToAction != null) ...[
            const SizedBox(height: AppDimensions.paddingM),
            _buildCallToActionButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildCallToActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          widget.advertisement.callToAction!,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Options de publicité',
              style: AppTextStyles.h3.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              icon: Icons.info_outline,
              title: 'Pourquoi cette pub ?',
              subtitle: 'Comprendre pourquoi vous voyez cette publicité',
              onTap: () {
                Navigator.pop(context);
                _showTargetingExplanation();
              },
            ),
            _buildOptionTile(
              icon: Icons.report_outlined,
              title: 'Signaler cette publicité',
              subtitle: 'Signaler un contenu inapproprié',
              onTap: () {
                Navigator.pop(context);
                _showReportDialog();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(color: Colors.grey.shade600),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showTargetingExplanation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pourquoi cette publicité ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cette publicité vous est montrée pour les raisons suivantes :',
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: 16),
            _buildExplanationItem(
              icon: Icons.location_on,
              text: widget.advertisement.targetLocation != null
                  ? 'Basée sur votre localisation'
                  : 'Publicité générale',
            ),
            if (widget.advertisement.targetingCriteria.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildExplanationItem(
                icon: Icons.person,
                text: 'Basée sur vos préférences',
              ),
            ],
            const SizedBox(height: 8),
            _buildExplanationItem(
              icon: Icons.schedule,
              text: 'Publicité active et récente',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler cette publicité'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pourquoi souhaitez-vous signaler cette publicité ?',
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: 16),
            ...['Contenu inapproprié', 'Publicité trompeuse', 'Spam', 'Autre']
                .map((reason) => ListTile(
                      title: Text(reason),
                      onTap: () {
                        Navigator.pop(context);
                        _reportAd(reason);
                      },
                      contentPadding: EdgeInsets.zero,
                    )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _reportAd(String reason) {
    if (widget.onReport != null) {
      widget.onReport!();
    }
    
    SnackBarHelper.showSuccess(
      context,
      'Publicité signalée. Merci pour votre retour.',
    );
  }
}