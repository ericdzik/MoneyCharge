import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/providers/ad_provider.dart';

class ManageAdsScreen extends StatefulWidget {
  const ManageAdsScreen({super.key});

  @override
  _ManageAdsScreenState createState() => _ManageAdsScreenState();
}

class _ManageAdsScreenState extends State<ManageAdsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch ads when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdProvider>(context, listen: false).fetchAds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Gérer les publicités',
        showLogo: false,
      ),
      body: Consumer<AdProvider>(
        builder: (context, adProvider, child) {
          if (adProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (adProvider.error != null) {
            return Center(child: Text('Erreur: ${adProvider.error}'));
          }

          if (adProvider.ads.isEmpty) {
            return const Center(child: Text('Aucune publicité à afficher.'));
          }

          return ListView.builder(
            itemCount: adProvider.ads.length,
            itemBuilder: (context, index) {
              final ad = adProvider.ads[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: CachedNetworkImage(
                      imageUrl: ad.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const LoadingIndicator.small(),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                  title: Text(ad.title),
                  subtitle: Text(ad.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await DialogHelper.showConfirmation(
                        context,
                        title: 'Confirmer la suppression',
                        message: 'Voulez-vous vraiment supprimer cette publicité ?',
                        confirmText: 'Supprimer',
                        isDangerous: true,
                      );

                      if (confirm == true) {
                        final adProvider = Provider.of<AdProvider>(context, listen: false);
                        await adProvider.deleteAd(ad.id, ad.imageUrl);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.adminAddAd);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
