import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String name,
    required String role,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'phone': null,
        'isActive': true,
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user profile in Firestore: $e');
      throw Exception('Erreur lors de la création du profil utilisateur.');
    }
  }

  Future<void> registerMerchant({
    required String businessName,
    required String email,
    required String phone,
    required String address,
    required Map<String, dynamic> openingHours,
    required List<String> services,
    required String password,
    required double? latitude,
    required double? longitude,
    required String merchantType,
    required String profileType,
    required List<String> supportedOperators,
    required List<String> moneyTransferTypes,
  }) async {
    try {
      final userCredential = await fb_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user?.uid;

      if (uid != null) {
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'email': email,
          'name': businessName,
          'role': 'merchant',
          'merchantType': merchantType,
          'profileType': profileType,
          'createdAt': FieldValue.serverTimestamp(),
          'phone': phone,
          'address': address,
          'openingHours': openingHours,
          'services': services,
          'isVerified': false,
          'isActive': true,
          'lastLoginAt': FieldValue.serverTimestamp(),
          'latitude': latitude,
          'longitude': longitude,
          'supportedOperators': supportedOperators,
          'moneyTransferTypes': moneyTransferTypes,
        });
      } else {
        throw Exception("Erreur lors de la création du compte marchand.");
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Le mot de passe est trop faible.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Cette adresse e-mail est déjà utilisée.');
      } else {
        throw Exception('Erreur d\'inscription: ${e.message}');
      }
    } catch (e) {
      throw Exception("Une erreur inconnue est survenue: ${e.toString()}");
    }
  }
}
