import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Service d'authentification unifié.
///
/// API publique conservée pour compatibilité production.
class AuthService {
  final fb_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  // Logger silencieux en release, verbeux en debug.
  static final Logger _logger = Logger(
    filter: _ReleaseAwareFilter(),
    printer: PrettyPrinter(noBoxingByDefault: true, methodCount: 0),
  );

  AuthService({
    fb_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  // Connexion unifiée — retourne l'UID en cas de succès, sinon null
  Future<String?> loginUnified(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } on fb_auth.FirebaseAuthException catch (e, s) {
      _logger.log(
        Level.warning,
        'Firebase Auth (Login): ${e.code} - ${e.message}',
        error: e,
        stackTrace: s,
      );
      throw _mapLoginException(e);
    } catch (e, s) {
      _logger.log(Level.error, 'Login Error', error: e, stackTrace: s);
      throw Exception('Une erreur inconnue est survenue.');
    }
  }

  // Inscription utilisateur — retourne l'UID en cas de succès, sinon null
  Future<String?> registerUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        await _createUserProfileInFirestore(
          uid: user.uid,
          email: email,
          name: name,
          role: 'user',
        );
        return user.uid;
      }
      return null;
    } on fb_auth.FirebaseAuthException catch (e, s) {
      _logger.log(
        Level.warning,
        'Firebase Auth (Register): ${e.code} - ${e.message}',
        error: e,
        stackTrace: s,
      );
      throw _mapRegisterException(e);
    } catch (e, s) {
      _logger.log(Level.error, 'Register Error', error: e, stackTrace: s);
      throw Exception('Une erreur inconnue est survenue.');
    }
  }

  Future<void> _createUserProfileInFirestore({
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
    } catch (e, s) {
      _logger.log(
        Level.error,
        'Firestore profile creation failed',
        error: e,
        stackTrace: s,
      );
      throw Exception('Erreur lors de la création du profil utilisateur.');
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e, s) {
      // La déconnexion est généralement sûre; on log l'erreur sans perturber l'app.
      _logger.log(Level.warning, 'Logout Error', error: e, stackTrace: s);
    }
  }

  // État session
  bool isLoggedIn() => _firebaseAuth.currentUser != null;

  String? getCurrentUserId() => _firebaseAuth.currentUser?.uid;

  String? getCurrentUserEmail() => _firebaseAuth.currentUser?.email;

  Stream<fb_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  // Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb_auth.FirebaseAuthException catch (e, s) {
      _logger.log(
        Level.warning,
        'Firebase Auth (Reset Password): ${e.code} - ${e.message}',
        error: e,
        stackTrace: s,
      );
      throw _mapResetPasswordException(e);
    } catch (e, s) {
      _logger.log(Level.error, 'Reset Password Error', error: e, stackTrace: s);
      throw Exception('Une erreur inconnue est survenue.');
    }
  }

  // Sauvegarde du token FCM
  Future<void> saveFCMToken(String token) async {
    final userId = getCurrentUserId();
    if (userId == null) return;

    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    } catch (e, s) {
      // Échec acceptable; on pourra réessayer plus tard.
      _logger.log(
        Level.warning,
        'Error saving FCM token',
        error: e,
        stackTrace: s,
      );
    }
  }

  // Mapping des erreurs — messages conservés pour compatibilité UI.
  Exception _mapLoginException(fb_auth.FirebaseAuthException e) {
    if (e.code == 'user-not-found' || e.code == 'wrong-password') {
      return Exception('Email ou mot de passe incorrect.');
    }
    if (e.code == 'invalid-email') {
      return Exception('L\'adresse e-mail n\'est pas valide.');
    }
    return Exception('Erreur de connexion. Veuillez réessayer.');
  }

  Exception _mapRegisterException(fb_auth.FirebaseAuthException e) {
    if (e.code == 'weak-password') {
      return Exception('Le mot de passe est trop faible.');
    }
    if (e.code == 'email-already-in-use') {
      return Exception('Cette adresse e-mail est déjà utilisée.');
    }
    if (e.code == 'invalid-email') {
      return Exception('L\'adresse e-mail n\'est pas valide.');
    }
    return Exception('Erreur d\'inscription. Veuillez réessayer.');
  }

  Exception _mapResetPasswordException(fb_auth.FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      return Exception('Aucun utilisateur trouvé pour cet e-mail.');
    }
    if (e.code == 'invalid-email') {
      return Exception('L\'adresse e-mail n\'est pas valide.');
    }
    return Exception(
      'Erreur lors de l\'envoi de l\'e-mail de réinitialisation.',
    );
  }
}

class _ReleaseAwareFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => !kReleaseMode;
}
