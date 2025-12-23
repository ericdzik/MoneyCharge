import 'package:flutter/material.dart';
import '../../../core/common.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/color_utils.dart';
import '../models/merchant_model.dart';

class MerchantListWidget extends StatefulWidget {
  final List<Merchant> merchants;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final Function(Merchant)? onMerchantTap;

  const MerchantListWidget({
    super.key,
    required this.merchants,
    this.isLoading = false,
    this.onLoadMore,
    this.onMerchantTap,
  });

  @override
  State<MerchantListWidget> createState() => _MerchantListWidgetState();
}

class _MerchantListWidgetState extends State<MerchantListWidget> {
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 10;
  final int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (!widget.isLoading && widget.onLoadMore != null) {
      widget.onLoadMore!();
    }
  }

  List<Merchant> get _visibleMerchants {
    final endIndex = (_currentPage + 1) * _pageSize;
    return widget.merchants.take(endIndex).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.merchants.isEmpty && !widget.isLoading) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _visibleMerchants.length + (widget.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _visibleMerchants.length) {
          return _buildLoadingIndicator();
        }

        final merchant = _visibleMerchants[index];
        return _buildMerchantCard(merchant);
      },
    );
  }

  Widget _buildMerchantCard(Merchant merchant) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Text(
            merchant.name[0].toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          merchant.name,
          style: AppTextStyles.h3,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              merchant.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${merchant.distance.toStringAsFixed(1)} km',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 80) {
              // Pour les très petits écrans, afficher seulement l'icône
              return _buildStatusIcon(merchant.status);
            } else {
              // Pour les écrans plus larges, afficher le chip complet
              return _buildStatusChip(merchant.status);
            }
          },
        ),
        onTap: () => widget.onMerchantTap?.call(merchant),
      ),
    );
  }

  Widget _buildStatusIcon(MerchantStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case MerchantStatus.available:
        color = AppColors.available;
        icon = Icons.check_circle;
        break;
      case MerchantStatus.lowStock:
        color = AppColors.lowStock;
        icon = Icons.warning;
        break;
      case MerchantStatus.outOfStock:
        color = AppColors.outOfStock;
        icon = Icons.cancel;
        break;
    }

    return Icon(icon, color: color, size: 20);
  }

  Widget _buildStatusChip(MerchantStatus status) {
    Color color;
    String text;

    switch (status) {
      case MerchantStatus.available:
        color = AppColors.available;
        text = 'Disponible';
        break;
      case MerchantStatus.lowStock:
        color = AppColors.lowStock;
        text = 'Stock faible';
        break;
      case MerchantStatus.outOfStock:
        color = AppColors.outOfStock;
        text = 'Rupture';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 64,
            color: ColorUtils.blackWithAlpha(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun point de service trouvé',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const LoadingIndicator(),
    );
  }
}
