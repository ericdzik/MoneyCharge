import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'auth_exception.dart';
import 'user_service.dart';

class AuthService {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final UserService _userService = UserService();

  Future<String?> loginUnified(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthException('unknown', 'Une erreur inconnue est survenue.');
    }
  }

  Future<String?> registerUser(String name, String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        await _userService.createUserProfile(
          uid: user.uid,
          email: email,
          name: name,
          role: 'user',
        );
        return user.uid;
      }
      return null;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthException('unknown', 'Une erreur inconnue est survenue.');
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      // La déconnexion échoue rarement, mais si c'est le cas, il n'y a pas grand-chose à faire.
      print('Logout Error: $e');
    }
  }

  bool isLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

  String? getCurrentUserEmail() {
    return _firebaseAuth.currentUser?.email;
  }

  Stream<fb_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthException('unknown', 'Une erreur inconnue est survenue.');
    }
  }

  AuthException _handleAuthException(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
        return AuthException('invalid-credentials', 'Email ou mot de passe incorrect.');
      case 'invalid-email':
        return AuthException('invalid-email', 'L\'adresse e-mail n\'est pas valide.');
      case 'weak-password':
        return AuthException('weak-password', 'Le mot de passe est trop faible.');
      case 'email-already-in-use':
        return AuthException('email-already-in-use', 'Cette adresse e-mail est déjà utilisée.');
      default:
        return AuthException(e.code, e.message ?? 'Erreur d\'authentification.');
    }
  }
}
