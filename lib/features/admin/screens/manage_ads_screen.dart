import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/providers/ad_provider.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';
import 'package:locacharge/core/constants/app_routes.dart';

class ManageAdsScreen extends StatefulWidget {
  const ManageAdsScreen({Key? key}) : super(key: key);

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
            return const Center(child: CircularProgressIndicator());
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
                  leading: Image.network(ad.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(ad.title),
                  subtitle: Text(ad.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmer la suppression'),
                          content: const Text('Voulez-vous vraiment supprimer cette publicité ?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Supprimer'),
                            ),
                          ],
                        ),
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
