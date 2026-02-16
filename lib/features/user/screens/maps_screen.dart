import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/utils/responsive_helper.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';
import 'package:locacharge/core/widgets/custom_drawer.dart';
import 'package:locacharge/features/user/widgets/map_widget.dart';
import 'package:locacharge/features/user/widgets/search_bar_widget.dart';
import 'package:locacharge/features/user/widgets/filter_widget.dart';
import 'package:locacharge/providers/merchant_provider.dart';
import 'package:locacharge/providers/location_provider.dart';
import 'package:locacharge/providers/ad_provider.dart';

class MapViewContent extends StatefulWidget {
  final Function(GoogleMapController)? onMapCreated;

  const MapViewContent({super.key, this.onMapCreated});

  @override
  State<MapViewContent> createState() => _MapViewContentState();
}

class _MapViewContentState extends State<MapViewContent> {
  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  void _initializeProviders() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MerchantProvider>().listenToMerchants();
      context.read<LocationProvider>().initialize();
      context.read<AdProvider>().fetchAds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.merchants.isEmpty) {
          return Container(
            color: AppColors.primary.withValues(alpha: 0.1),
            child: const LoadingIndicator(),
          );
        }

        if (provider.error != null) {
          return Container(
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Text(
                      "Erreur: ${provider.error}",
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        if (provider.merchants.isEmpty) {
          return Container(
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Text(
                      "Aucun point de service trouvé.",
                      style: AppTextStyles.body1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return MapWidget(
          merchants: provider.merchants,
          onMerchantSelected: (merchant) {
            Navigator.pushNamed(
              context,
              AppRoutes.merchantDetail,
              arguments: {'merchant': merchant},
            );
          },
          showUserLocation: true,
          initialZoom: 13.0,
          onMapCreated: widget.onMapCreated,
        );
      },
    );
  }
}

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> with TickerProviderStateMixin {
  bool _showSearchPanel = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(
        title: 'Carte',
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showSearchPanel ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() => _showSearchPanel = !_showSearchPanel);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.notifications),
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _showSearchPanel
                ? Builder(
                    builder: (context) {
                      final horizontalPadding =
                          ResponsiveHelper.getHorizontalMargin(context);
                      final verticalPadding =
                          context.isExtraSmall ? 6.0 : 8.0;
                      return Container(
                        color: AppColors.success,
                        margin: const EdgeInsets.only(
                          top: AppDimensions.paddingS,
                        ),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          verticalPadding,
                          horizontalPadding,
                          verticalPadding,
                        ),
                        child: Column(
                          children: const [
                            SearchBarWidget(),
                            SizedBox(height: 8),
                            FilterWidget(),
                          ],
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),
          const Expanded(child: MapViewContent()),
        ],
      ),
    );
  }
}
