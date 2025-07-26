import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/merchant_card.dart';
import '../../../providers/merchant_provider.dart';
import 'merchant_detail_screen.dart';
import '../models/merchant_model.dart'; // Ajout de l'import pour Merchant
import 'map_view_screen.dart'; // Ajout de l'import pour MapViewScreen
// import '../../../services/location_service.dart'; // Retiré car plus utilisé directement
import '../../../core/constants/app_routes.dart'; // Ajout de l'import pour AppRoutes

class ListViewScreen extends StatefulWidget {
  final GoogleMapController? mapController;
  const ListViewScreen({Key? key, this.mapController}) : super(key: key);

  @override
  State<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MerchantProvider>(context, listen: false).listenToMerchants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/splash/33.png', fit: BoxFit.cover),
          ),
          Column(
            children: [
              Expanded(
                child: Consumer<MerchantProvider>(
                  builder: (context, merchantProvider, child) {
                    if (merchantProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (merchantProvider.merchants.isEmpty) {
                      return const Center(
                        child: Text('Aucun point de service trouvé'),
                      );
                    }

                    return RefreshIndicator(
                  onRefresh: () {
                    merchantProvider.refreshMerchants();
                    return Future.value();
                  },
                      child: ListView.builder(
                        itemCount: merchantProvider.merchants.length,
                        itemBuilder: (context, index) {
                          final merchant = merchantProvider.merchants[index];
                          return MerchantCard(
                            merchant: merchant,
                            onTap: () {
                              if (widget.mapController != null) {
                                widget.mapController!.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    LatLng(merchant.latitude, merchant.longitude),
                                    16.0,
                                  ),
                                );
                              }
                              Navigator.pushNamed(
                                context,
                                AppRoutes.merchantDetail,
                                arguments: {'merchant': merchant},
                              );
                            },
                            onDirectionsPressed: () {
                              _openDirections(merchant);
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openDirections(Merchant merchant) {
    Navigator.pushNamed(
      context,
      AppRoutes.mapView,
      arguments: {'merchant': merchant},
    );
  }
}
