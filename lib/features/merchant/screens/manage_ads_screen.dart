import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../providers/ad_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/constants/app_routes.dart';

class ManageMerchantAdsScreen extends StatefulWidget {
  const ManageMerchantAdsScreen({Key? key}) : super(key: key);

  @override
  _ManageMerchantAdsScreenState createState() => _ManageMerchantAdsScreenState();
}

class _ManageMerchantAdsScreenState extends State<ManageMerchantAdsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.merchantProfile != null) {
        Provider.of<AdProvider>(context, listen: false).fetchMyAds(authProvider.merchantProfile!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mes Publicités',
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
            return const Center(child: Text('Vous n\'avez aucune publicité pour le moment.'));
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
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
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
          Navigator.pushNamed(context, AppRoutes.merchantAddAd);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
