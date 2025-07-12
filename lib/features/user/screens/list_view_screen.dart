import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/merchant_card.dart';
import '../../../providers/merchant_provider.dart';
import '../widgets/filter_bar_widget.dart';
import 'merchant_detail_screen.dart';
import '../models/merchant_model.dart'; // Ajout de l'import pour Merchant
import 'map_view_screen.dart'; // Ajout de l'import pour MapViewScreen
// import '../../../services/location_service.dart'; // Retiré car plus utilisé directement

class ListViewScreen extends StatefulWidget {
  const ListViewScreen({Key? key}) : super(key: key);

  @override
  State<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MerchantProvider>(context, listen: false).loadMerchants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Points de service',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const FilterBarWidget(),
          Expanded(
            child: Consumer<MerchantProvider>(
              builder: (context, merchantProvider, child) {
                if (merchantProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (merchantProvider.merchants.isEmpty) {
                  return const Center(
                    child: Text('Aucun point de service trouvé'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => merchantProvider.loadMerchants(),
                  child: ListView.builder(
                    itemCount: merchantProvider.merchants.length,
                    itemBuilder: (context, index) {
                      final merchant = merchantProvider.merchants[index];
                      return MerchantCard(
                        merchant: merchant,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MerchantDetailScreen(
                                merchant: merchant,
                              ),
                            ),
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
    );
  }

  void _openDirections(Merchant merchant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapViewScreen(targetMerchant: merchant),
      ),
    );
  }
}