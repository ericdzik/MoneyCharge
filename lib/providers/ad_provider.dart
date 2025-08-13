import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locacharge/services/storage_service.dart';
import '../models/ad_model.dart';

class AdProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  List<Ad> _ads = [];
  bool _isLoading = false;
  String? _error;

  List<Ad> get ads => _ads;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAds() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final adsSnapshot = await _firestore
          .collection('ads')
          .orderBy('createdAt', descending: true)
          .get();
      _ads = adsSnapshot.docs
          .map((doc) => Ad.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      print("Error in fetchAds: $e");
      _error = "Erreur lors de la récupération des publicités: ${e.toString()}";
      _ads = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyAds(String merchantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final adsSnapshot = await _firestore
          .collection('ads')
          .where('merchantId', isEqualTo: merchantId)
          .orderBy('createdAt', descending: true)
          .get();
      _ads = adsSnapshot.docs
          .map((doc) => Ad.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      print("Error in fetchMyAds: $e");
      _error = "Erreur lors de la récupération de vos publicités: ${e.toString()}";
      _ads = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAd({
    required String title,
    required String description,
    required XFile image,
    required String url,
    required String merchantId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final imageUrl = await _storageService.uploadAdImage(image);
      if (imageUrl == null) {
        _error = "Erreur lors de l'upload de l'image.";
        return false;
      }

      final newAd = Ad(
        id: '',
        title: title,
        description: description,
        imageUrl: imageUrl,
        url: url,
        createdAt: Timestamp.now(),
        merchantId: merchantId,
      );

      await _firestore.collection('ads').add(
        newAd.toFirestoreMap()
          ..['createdAt'] = FieldValue.serverTimestamp(),
      );

      await fetchAds();
      return true;
    } catch (e) {
      print("Error in addAd: $e");
      _error = "Erreur lors de l'ajout de la publicité: ${e.toString()}";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAd(String adId, String imageUrl) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First, delete the ad document from Firestore
      await _firestore.collection('ads').doc(adId).delete();

      // Then, delete the ad image from Storage
      await _storageService.deleteAdImage(imageUrl);

      // Refresh the ads list
      await fetchAds();
      return true;
    } catch (e) {
      print("Error in deleteAd: $e");
      _error = "Erreur lors de la suppression de la publicité: ${e.toString()}";
      // If deletion fails, refresh the ads list to ensure UI consistency
      await fetchAds();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
