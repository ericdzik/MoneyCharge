import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class AuthService {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance de Firestore


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
      print('Firebase Auth Exception (Login): ${e.code} - ${e.message}');
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw Exception('Email ou mot de passe incorrect.');
      } else if (e.code == 'invalid-email') {
        throw Exception('L\'adresse e-mail n\'est pas valide.');
      } else {
        throw Exception('Erreur de connexion. Veuillez réessayer.');
      }
    } catch (e) {
      print('Login Error: $e');
      throw Exception('Une erreur inconnue est survenue.');
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
          role: 'user', // Le rôle est 'user' par défaut pour l'inscription standard
        );
        return user.uid;
      }
      return null; // Ne devrait pas arriver si createUserWithEmailAndPassword réussit
    } on fb_auth.FirebaseAuthException catch (e) {
      print('Firebase Auth Exception (Register): ${e.code} - ${e.message}');
      if (e.code == 'weak-password') {
        throw Exception('Le mot de passe est trop faible.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Cette adresse e-mail est déjà utilisée.');
      } else if (e.code == 'invalid-email') {
        throw Exception('L\'adresse e-mail n\'est pas valide.');
      } else {
        throw Exception('Erreur d\'inscription. Veuillez réessayer.');
      }
    } catch (e) {
      print('Register Error: $e');
      throw Exception('Une erreur inconnue est survenue.');
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
      if (e.code == 'user-not-found') {
        throw Exception('Aucun utilisateur trouvé pour cet e-mail.');
      } else if (e.code == 'invalid-email') {
        throw Exception('L\'adresse e-mail n\'est pas valide.');
      } else {
        throw Exception('Erreur lors de l\'envoi de l\'e-mail de réinitialisation.');
      }
    } catch (e) {
      print('Reset Password Error: $e');
      throw Exception('Une erreur inconnue est survenue.');
    }
  }

}
