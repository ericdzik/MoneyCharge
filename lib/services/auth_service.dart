import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userTypeKey = 'user_type';
  static const String _userIdKey = 'user_id';

  // Détecter automatiquement le type d'utilisateur basé sur l'email
  String _detectUserType(String email) {
    final emailLower = email.toLowerCase();

    // Logique de détection du rôle basée sur l'email
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

  // Connexion unifiée qui détecte automatiquement le type d'utilisateur
  Future<bool> loginUnified(String email, String password) async {
    try {
      // Simulation d'une API call
      await Future.delayed(const Duration(seconds: 1));

      // Pour la démo, on accepte n'importe quel email/password
      if (email.isNotEmpty && password.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final userType = _detectUserType(email);

        await prefs.setString(
          _tokenKey,
          '${userType}_token_${DateTime.now().millisecondsSinceEpoch}',
        );
        await prefs.setString(_userTypeKey, userType);
        await prefs.setString(
          _userIdKey,
          '${userType}_${DateTime.now().millisecondsSinceEpoch}',
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Connexion utilisateur
  Future<bool> loginUser(String email, String password) async {
    try {
      // Simulation d'une API call
      await Future.delayed(const Duration(seconds: 1));

      // Pour la démo, on accepte n'importe quel email/password
      if (email.isNotEmpty && password.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _tokenKey,
          'user_token_${DateTime.now().millisecondsSinceEpoch}',
        );
        await prefs.setString(_userTypeKey, 'user');
        await prefs.setString(
          _userIdKey,
          'user_${DateTime.now().millisecondsSinceEpoch}',
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Connexion marchand
  Future<bool> loginMerchant(String email, String password) async {
    try {
      // Simulation d'une API call
      await Future.delayed(const Duration(seconds: 1));

      // Pour la démo, on accepte n'importe quel email/password
      if (email.isNotEmpty && password.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _tokenKey,
          'merchant_token_${DateTime.now().millisecondsSinceEpoch}',
        );
        await prefs.setString(_userTypeKey, 'merchant');
        await prefs.setString(
          _userIdKey,
          'merchant_${DateTime.now().millisecondsSinceEpoch}',
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Connexion admin
  Future<bool> loginAdmin(String email, String password) async {
    try {
      // Simulation d'une API call
      await Future.delayed(const Duration(seconds: 1));

      // Pour la démo, on accepte n'importe quel email/password
      if (email.isNotEmpty && password.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _tokenKey,
          'admin_token_${DateTime.now().millisecondsSinceEpoch}',
        );
        await prefs.setString(_userTypeKey, 'admin');
        await prefs.setString(
          _userIdKey,
          'admin_${DateTime.now().millisecondsSinceEpoch}',
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Inscription utilisateur
  Future<bool> registerUser(String name, String email, String password) async {
    try {
      // Simulation d'une API call
      await Future.delayed(const Duration(seconds: 1));

      // Pour la démo, on accepte n'importe quelles données
      if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _tokenKey,
          'user_token_${DateTime.now().millisecondsSinceEpoch}',
        );
        await prefs.setString(_userTypeKey, 'user');
        await prefs.setString(
          _userIdKey,
          'user_${DateTime.now().millisecondsSinceEpoch}',
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userTypeKey);
    await prefs.remove(_userIdKey);
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Obtenir le type d'utilisateur
  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }

  // Obtenir l'ID de l'utilisateur
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Réinitialiser le mot de passe
  Future<bool> resetPassword(String email) async {
    try {
      // Simulation d'une API call
      await Future.delayed(const Duration(seconds: 1));

      // Pour la démo, on accepte n'importe quel email
      return email.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
