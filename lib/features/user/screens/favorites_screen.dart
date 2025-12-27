import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/widgets/merchant_card.dart';
import 'package:locacharge/core/widgets/unified_sliver_app_bar.dart';
import 'package:locacharge/providers/favorite_merchant_provider.dart';
import 'package:locacharge/providers/merchant_provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    setState(() {
      _appBarOpacity = (_scrollController.offset / 120).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: AppColors.background,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            UnifiedSliverAppBar(
              opacity: _appBarOpacity,
              title: 'Mes Favoris',
              subtitle: '',
              icon: Icons.favorite_rounded,
            ),
            SliverToBoxAdapter(
              child: Consumer<FavoriteMerchantProvider>(
              builder: (context, favoriteProvider, child) {
                if (favoriteProvider.isLoading) {
                  return const SizedBox(
                    height: 400,
                    child: Center(child: LoadingIndicator()),
                  );
                }

                if (favoriteProvider.favoriteMerchantIds.isEmpty) {
                  return const _EmptyFavoritesState();
                }

                return Consumer<MerchantProvider>(
                  builder: (context, merchantProvider, child) {
                    if (merchantProvider.isLoading &&
                        merchantProvider.merchants.isEmpty) {
                      return const SizedBox(
                        height: 400,
                        child: Center(child: LoadingIndicator()),
                      );
                    }

                    if (merchantProvider.error != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.paddingXL),
                          child: Text(
                            "Erreur: ${merchantProvider.error}",
                            style: AppTextStyles.body1.copyWith(
                              color: AppColors.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final favoriteMerchants = merchantProvider.merchants
                        .where((merchant) =>
                            favoriteProvider.isFavorite(merchant.id))
                        .toList();

                    if (favoriteMerchants.isEmpty) {
                      return const _EmptyFavoritesState();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.paddingM,
                            AppDimensions.paddingL,
                            AppDimensions.paddingM,
                            AppDimensions.paddingM,
                          ),
                          child: _SectionHeader(count: favoriteMerchants.length),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                          ),
                          itemCount: favoriteMerchants.length,
                          itemBuilder: (context, index) {
                            final merchant = favoriteMerchants[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppDimensions.paddingM,
                              ),
                              child: MerchantCard(
                                merchant: merchant,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.merchantDetail,
                                    arguments: {'merchant': merchant},
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppDimensions.paddingXL),
                      ],
                    );
                  },
                );
              },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MODERN UI WIDGETS
// ============================================================================

class _SectionHeader extends StatelessWidget {
  final int count;

  const _SectionHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vos favoris', style: AppTextStyles.h2),
            const SizedBox(height: 4),
            Text(
              '$count marchand${count > 1 ? 's' : ''}',
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
          icon: const Icon(Icons.explore_rounded, size: 18),
          label: const Text('Explorer'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _EmptyFavoritesState extends StatelessWidget {
  const _EmptyFavoritesState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border_rounded,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'Aucun favori pour le moment',
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            'Ajoutez des marchands à vos favoris pour les retrouver rapidement.',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingL),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
            icon: const Icon(Icons.explore_rounded),
            label: const Text('Explorer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
