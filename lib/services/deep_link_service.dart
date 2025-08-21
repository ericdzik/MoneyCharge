import 'dart:async';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locacharge/core/constants/app_routes.dart';
import 'package:locacharge/features/user/models/merchant_model.dart';
import 'navigation_service.dart';

class DeepLinkService {
  StreamSubscription? _sub;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initUniLinks() async {
    // Listen for incoming links when the app is already running
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _navigateToContent(uri);
      }
    }, onError: (err) {
      print('uni_links error: $err');
    });

    // Handle the link that opened the app from a terminated state
    try {
      final Uri? initialUri = await getInitialUri();
      if (initialUri != null) {
        _navigateToContent(initialUri);
      }
    } on PlatformException {
      print('Failed to get initial uri.');
    }
  }

  Future<void> _navigateToContent(Uri deepLink) async {
    // Assuming the domain is 'locacharge.app' and path is '/merchants/:id'
    if (deepLink.host.contains('locacharge.app') && deepLink.pathSegments.contains('merchants')) {
      final String? merchantId = deepLink.pathSegments.last;
      if (merchantId != null) {
        try {
          final docSnapshot = await _firestore.collection('users').doc(merchantId).get();
          if (docSnapshot.exists) {
            final merchant = Merchant.fromFirestoreUserDoc(docSnapshot);
            NavigationService.navigatorKey.currentState?.pushNamed(
              AppRoutes.merchantDetail,
              arguments: {'merchant': merchant},
            );
          } else {
            print('Merchant with ID $merchantId not found.');
          }
        } catch (e) {
          print('Error fetching merchant details for deep link: $e');
        }
      }
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
