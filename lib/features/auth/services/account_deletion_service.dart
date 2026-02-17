import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';

/// Service de suppression de compte utilisateur
/// Gère la suppression complète des données utilisateur
class AccountDeletionService {
  final FirebaseFirestore _firestore;
  final fb_auth.FirebaseAuth _firebaseAuth;
  final FirebaseStorage _storage;
  final Logger _logger = Logger();

  AccountDeletionService({
    FirebaseFirestore? firestore,
    fb_auth.FirebaseAuth? firebaseAuth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// Supprime complètement le compte utilisateur
  /// Retourne true si succès, false sinon
  Future<bool> deleteAccount(String userId, String userRole) async {
    try {
      _logger.i('Début de la suppression du compte: $userId (role: $userRole)');

      // 1. Supprimer les données spécifiques selon le rôle
      if (userRole == 'merchant') {
        await _deleteMerchantData(userId);
      } else if (userRole == 'user') {
        await _deleteUserData(userId);
      }

      // 2. Supprimer les images de profil et galerie
      await _deleteUserImages(userId, userRole);

      // 3. Supprimer le document utilisateur principal
      await _firestore.collection('users').doc(userId).delete();
      _logger.i('Document utilisateur supprimé: $userId');

      // 4. Supprimer le compte Firebase Auth
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        await currentUser.delete();
        _logger.i('Compte Firebase Auth supprimé: $userId');
      }

      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      _logger.e('Erreur Firebase Auth lors de la suppression: ${e.code}');
      if (e.code == 'requires-recent-login') {
        throw Exception(
          'Pour des raisons de sécurité, veuillez vous reconnecter avant de supprimer votre compte.',
        );
      }
      throw Exception('Erreur lors de la suppression du compte: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e(
        'Erreur lors de la suppression du compte',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Une erreur est survenue lors de la suppression du compte.');
    }
  }

  /// Supprime les données spécifiques aux marchands
  Future<void> _deleteMerchantData(String merchantId) async {
    try {
      final batch = _firestore.batch();

      // Supprimer les factures
      final invoices = await _firestore
          .collection('invoices')
          .where('merchantId', isEqualTo: merchantId)
          .get();
      for (var doc in invoices.docs) {
        batch.delete(doc.reference);
      }

      // Supprimer les transactions
      final transactions = await _firestore
          .collection('transactions')
          .where('merchantId', isEqualTo: merchantId)
          .get();
      for (var doc in transactions.docs) {
        batch.delete(doc.reference);
      }

      // Supprimer les avis/reviews
      final reviews = await _firestore
          .collection('reviews')
          .where('merchantId', isEqualTo: merchantId)
          .get();
      for (var doc in reviews.docs) {
        batch.delete(doc.reference);
      }

      // Supprimer les publicités
      final ads = await _firestore
          .collection('advertisements')
          .where('merchantId', isEqualTo: merchantId)
          .get();
      for (var doc in ads.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _logger.i('Données marchand supprimées: $merchantId');
    } catch (e) {
      _logger.e('Erreur lors de la suppression des données marchand: $e');
      rethrow;
    }
  }

  /// Supprime les données spécifiques aux utilisateurs
  Future<void> _deleteUserData(String userId) async {
    try {
      final batch = _firestore.batch();

      // Supprimer les favoris
      final favorites = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in favorites.docs) {
        batch.delete(doc.reference);
      }

      // Supprimer les avis écrits par l'utilisateur
      final reviews = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in reviews.docs) {
        batch.delete(doc.reference);
      }

      // Supprimer les préférences utilisateur
      final prefs = await _firestore
          .collection('user_preferences')
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in prefs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _logger.i('Données utilisateur supprimées: $userId');
    } catch (e) {
      _logger.e('Erreur lors de la suppression des données utilisateur: $e');
      rethrow;
    }
  }

  /// Supprime les images de l'utilisateur dans Storage
  Future<void> _deleteUserImages(String userId, String userRole) async {
    try {
      // Supprimer l'image de profil
      final profileImagePath = userRole == 'merchant'
          ? 'merchant_profile_images/$userId.jpg'
          : 'user_profile_images/$userId.jpg';

      try {
        await _storage.ref(profileImagePath).delete();
        _logger.i('Image de profil supprimée: $profileImagePath');
      } catch (e) {
        _logger.w('Image de profil non trouvée ou déjà supprimée: $e');
      }

      // Supprimer les images de galerie (pour les marchands)
      if (userRole == 'merchant') {
        try {
          final galleryRef = _storage.ref('merchant_images/$userId');
          final listResult = await galleryRef.listAll();
          for (var item in listResult.items) {
            await item.delete();
          }
          _logger.i('Images de galerie supprimées pour: $userId');
        } catch (e) {
          _logger.w('Erreur lors de la suppression des images de galerie: $e');
        }
      }
    } catch (e) {
      _logger.e('Erreur lors de la suppression des images: $e');
      // Ne pas bloquer la suppression si les images ne peuvent pas être supprimées
    }
  }

  /// Vérifie si l'utilisateur peut supprimer son compte
  /// (par exemple, vérifier s'il n'a pas de transactions en cours)
  Future<bool> canDeleteAccount(String userId, String userRole) async {
    try {
      if (userRole == 'merchant') {
        // Vérifier s'il y a des transactions en attente
        final pendingTransactions = await _firestore
            .collection('transactions')
            .where('merchantId', isEqualTo: userId)
            .where('status', isEqualTo: 'pending')
            .limit(1)
            .get();

        if (pendingTransactions.docs.isNotEmpty) {
          throw Exception(
            'Vous avez des transactions en attente. Veuillez les finaliser avant de supprimer votre compte.',
          );
        }
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }
}
