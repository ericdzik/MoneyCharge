import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/providers/ad_provider.dart';
import 'package:locacharge/models/ad_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AdCarouselWidget extends StatefulWidget {
  const AdCarouselWidget({Key? key}) : super(key: key);

  @override
  _AdCarouselWidgetState createState() => _AdCarouselWidgetState();
}

class _AdCarouselWidgetState extends State<AdCarouselWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdProvider>(context, listen: false).fetchAds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdProvider>(
      builder: (context, adProvider, child) {
        if (adProvider.isLoading && adProvider.ads.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (adProvider.error != null) {
          return Center(child: Text(adProvider.error!));
        }

        if (adProvider.ads.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Annonces',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: adProvider.ads.length,
                itemBuilder: (context, index) {
                  final ad = adProvider.ads[index];
                  return AdCard(ad: ad);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class AdCard extends StatelessWidget {
  final Ad ad;

  const AdCard({Key? key, required this.ad}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse(ad.url);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Impossible d\'ouvrir le lien ${ad.url}'),
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            ad.imageUrl,
            fit: BoxFit.cover,
            width: 250,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Icon(Icons.error));
            },
          ),
        ),
      ),
    );
  }
}
