import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:locacharge/providers/ad_provider.dart';
import 'package:locacharge/models/ad_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AdCarouselWidget extends StatefulWidget {
  const AdCarouselWidget({Key? key}) : super(key: key);

  @override
  _AdCarouselWidgetState createState() => _AdCarouselWidgetState();
}

class _AdCarouselWidgetState extends State<AdCarouselWidget> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdProvider>(context, listen: false).fetchAds().then((_) {
        if (mounted && Provider.of<AdProvider>(context, listen: false).ads.isNotEmpty) {
          _startTimer();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final adProvider = Provider.of<AdProvider>(context, listen: false);
      if (adProvider.ads.isNotEmpty) {
        final nextPage = (_currentPage + 1) % adProvider.ads.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
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
              child: PageView.builder(
                controller: _pageController,
                itemCount: adProvider.ads.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final ad = adProvider.ads[index];
                  return AdCard(ad: ad);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(adProvider.ads.length, (index) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? const Color.fromRGBO(0, 0, 0, 0.9)
                        : const Color.fromRGBO(0, 0, 0, 0.4),
                  ),
                );
              }),
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
          child: CachedNetworkImage(
            imageUrl: ad.imageUrl,
            fit: BoxFit.cover,
            width: 250,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }
}
