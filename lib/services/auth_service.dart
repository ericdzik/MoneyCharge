import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class AuthService {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance de Firestore

  // La détection du type d'utilisateur basée sur l'email peut rester si elle est utilisée
  // avant l'inscription pour déterminer une logique spécifique, mais le rôle final
  // proviendra de Firestore après la connexion/inscription.
  String detectUserTypeFromEmail(String email) {
    final emailLower = email.toLowerCase();
    if (emailLower.contains('admin') ||
        emailLower.contains('@locacharge.com') ||
        emailLower.contains('administrator')) {
      return 'admin';
    } else if (emailLower.contains('merchant') ||
        emailLower.contains('boutique') ||
        emailLower.contains('shop') ||
        emailLower.contains('store') ||
        emailLower.contains('business')) {
      return 'merchant';
    } else {
      return 'user';
    }
  }

  // Connexion unifiée
  // Retourne l'UID de l'utilisateur en cas de succès, sinon null
  Future<String?> loginUnified(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } on fb_auth.FirebaseAuthException catch (e) {
      // Gérer les erreurs spécifiques de Firebase Auth (e.g., user-not-found, wrong-password)
      print('Firebase Auth Exception (Login): ${e.code} - ${e.message}');
      // On pourrait lancer une exception personnalisée ici pour être gérée par AuthProvider
      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      print('Login Error: $e');
      throw Exception('Erreur de connexion inconnue.');
    }
  }

  // Inscription utilisateur
  // Retourne l'UID de l'utilisateur en cas de succès, sinon null
  Future<String?> registerUser(String name, String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        // Créer le profil utilisateur dans Firestore
        await _createUserProfileInFirestore(
          uid: user.uid,
          email: email,
          name: name,
          // Le rôle initial peut être déterminé par la logique de l'email ou être 'user' par défaut
          role: detectUserTypeFromEmail(email),
        );
        return user.uid;
      }
      return null; // Ne devrait pas arriver si createUserWithEmailAndPassword réussit
    } on fb_auth.FirebaseAuthException catch (e) {
      print('Firebase Auth Exception (Register): ${e.code} - ${e.message}');
      throw Exception('Erreur d\'inscription: ${e.message}');
    } catch (e) {
      print('Register Error: $e');
      throw Exception('Erreur d\'inscription inconnue: $e');
    }
  }

  // Méthode privée pour créer le profil utilisateur dans Firestore
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
        'createdAt': FieldValue.serverTimestamp(), // Utilise le timestamp du serveur Firestore
        'phone': null, // Peut être ajouté/modifié plus tard
        'isActive': true,
        'lastLoginAt': FieldValue.serverTimestamp(), // Mettre à jour à la première connexion aussi
      });
    } catch (e) {
      // Gérer l'erreur de création de profil Firestore
      // Potentiellement, supprimer l'utilisateur de Firebase Auth si la création Firestore échoue
      // pour éviter les états inconsistants. C'est une logique de compensation plus avancée.
      print('Error creating user profile in Firestore: $e');
      throw Exception('Erreur lors de la création du profil utilisateur.');
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Logout Error: $e');
      // Gérer l'erreur si nécessaire, mais la déconnexion est généralement sûre.
    }
  }

  // Vérifier si l'utilisateur est connecté
  bool isLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  // Obtenir l'ID de l'utilisateur Firebase (UID)
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

  // Obtenir l'email de l'utilisateur Firebase
  String? getCurrentUserEmail() {
    return _firebaseAuth.currentUser?.email;
  }

  // Stream pour écouter les changements d'état d'authentification
  Stream<fb_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();


  // Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb_auth.FirebaseAuthException catch (e) {
      print('Firebase Auth Exception (Reset Password): ${e.code} - ${e.message}');
      throw Exception('Erreur de réinitialisation du mot de passe: ${e.message}');
    } catch (e) {
      print('Reset Password Error: $e');
      throw Exception('Erreur de réinitialisation du mot de passe inconnue.');
    }
  }

  // Les méthodes loginUser, loginMerchant, loginAdmin ne sont plus nécessaires si on utilise loginUnified
  // et que la distinction se fait via Firestore après la connexion.
  // La méthode getUserType() via SharedPreferences n'est plus pertinente pour le rôle Firebase.
  // Le rôle sera récupéré depuis Firestore.
}
