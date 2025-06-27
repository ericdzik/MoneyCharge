import 'package:flutter/foundation.dart';
import '../features/merchant/models/merchant_auth_model.dart';
import '../features/admin/models/admin_model.dart';
import '../services/auth_service.dart';

enum UserType { user, merchant, admin }

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.createdAt,
  });
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  // État d'authentification
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  UserType? _userType;

  // Données utilisateur
  User? _currentUser;

  // Données marchand
  MerchantAuthModel? _merchant;

  // Données admin
  AdminModel? _admin;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserType? get userType => _userType;
  User? get currentUser => _currentUser;
  MerchantAuthModel? get merchant => _merchant;
  AdminModel? get admin => _admin;

  // Initialisation
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final userType = await _authService.getUserType();
        final userId = await _authService.getUserId();

        if (userType != null && userId != null) {
          _isAuthenticated = true;
          _userType = _parseUserType(userType);

          // Créer un utilisateur temporaire pour la démo
          if (_userType == UserType.user) {
            _currentUser = User(
              id: userId,
              name: 'Utilisateur Demo',
              email: 'demo@example.com',
              phone: '+225 0123456789',
              createdAt: DateTime.now().subtract(const Duration(days: 30)),
            );
          }
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Connexion unifiée qui détecte automatiquement le type d'utilisateur
  Future<bool> loginUnified(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final success = await _authService.loginUnified(email, password);
      if (success) {
        final userType = await _authService.getUserType();
        final userId = await _authService.getUserId();

        if (userType != null && userId != null) {
          _isAuthenticated = true;
          _userType = _parseUserType(userType);

          // Créer l'utilisateur approprié selon le type
          switch (_userType) {
            case UserType.admin:
              _admin = AdminModel(
                id: userId,
                email: email,
                name: email.split('@')[0],
                role: AdminRole.admin,
                permissions: ['all'],
                createdAt: DateTime.now(),
              );
              break;
            case UserType.merchant:
              _merchant = MerchantAuthModel(
                id: userId,
                email: email,
                businessName: email.split('@')[0],
                phone: '+225 0123456789',
                address: 'Adresse du marchand',
                isVerified: true,
                createdAt: DateTime.now(),
              );
              break;
            case UserType.user:
            default:
              _currentUser = User(
                id: userId,
                name: email.split('@')[0],
                email: email,
                phone: '+225 0123456789',
                createdAt: DateTime.now(),
              );
              break;
          }

          notifyListeners();
          return true;
        }
      }

      _error = 'Email ou mot de passe incorrect';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Inscription utilisateur
  Future<bool> registerUser(String name, String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final success = await _authService.registerUser(name, email, password);
      if (success) {
        _isAuthenticated = true;
        _userType = UserType.user;

        final userId = await _authService.getUserId();
        _currentUser = User(
          id: userId ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          email: email,
          phone: '+225 0123456789',
          createdAt: DateTime.now(),
        );

        notifyListeners();
        return true;
      } else {
        _error = 'Erreur lors de l\'inscription';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Déconnexion
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _isAuthenticated = false;
      _userType = null;
      _currentUser = null;
      _merchant = null;
      _admin = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Réinitialiser le mot de passe
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _error = null;

    try {
      final success = await _authService.resetPassword(email);
      if (!success) {
        _error = 'Erreur lors de l\'envoi de l\'email';
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Méthode de debug pour forcer la connexion admin
  Future<void> forceAdminLogin() async {
    _setLoading(true);
    _error = null;

    try {
      _isAuthenticated = true;
      _userType = UserType.admin;

      _admin = AdminModel(
        id: 'debug_admin_${DateTime.now().millisecondsSinceEpoch}',
        email: 'admin@locacharge.com',
        name: 'Administrateur Debug',
        role: AdminRole.superAdmin,
        permissions: ['all'],
        createdAt: DateTime.now(),
      );

      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Méthode pour vérifier le statut d'authentification au démarrage
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final userType = await _authService.getUserType();
        final userId = await _authService.getUserId();

        if (userType != null && userId != null) {
          _isAuthenticated = true;
          _userType = _parseUserType(userType);

          // Créer un utilisateur temporaire pour la démo
          if (_userType == UserType.user) {
            _currentUser = User(
              id: userId,
              name: 'Utilisateur Demo',
              email: 'demo@example.com',
              phone: '+225 0123456789',
              createdAt: DateTime.now().subtract(const Duration(days: 30)),
            );
          } else if (_userType == UserType.merchant) {
            _merchant = MerchantAuthModel(
              id: userId,
              email: 'merchant@example.com',
              businessName: 'Marchand Demo',
              phone: '+225 0123456789',
              address: 'Adresse du marchand',
              isVerified: true,
              createdAt: DateTime.now().subtract(const Duration(days: 30)),
            );
          } else if (_userType == UserType.admin) {
            _admin = AdminModel(
              id: userId,
              email: 'admin@example.com',
              name: 'Admin Demo',
              role: AdminRole.admin,
              permissions: ['all'],
              createdAt: DateTime.now().subtract(const Duration(days: 30)),
            );
          }
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Inscription marchand avec informations complètes
  Future<bool> registerMerchant({
    required String businessName,
    required String email,
    required String phone,
    required String address,
    required String openingHours,
    required String services,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      // En mode démo, on simule l'inscription
      await Future.delayed(const Duration(seconds: 2));

      // Créer un profil marchand temporaire (en attente de validation)
      final userId = 'merchant_${DateTime.now().millisecondsSinceEpoch}';

      _merchant = MerchantAuthModel(
        id: userId,
        email: email,
        businessName: businessName,
        phone: phone,
        address: address,
        openingHours: openingHours,
        services: services,
        isVerified: false, // En attente de validation admin
        createdAt: DateTime.now(),
      );

      // En mode production, on enverrait ces données au serveur
      // await _authService.registerMerchant(merchantData);

      // Pour la démo, on connecte directement
      _isAuthenticated = true;
      _userType = UserType.merchant;

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Méthodes privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  UserType _parseUserType(String userType) {
    switch (userType.toLowerCase()) {
      case 'merchant':
        return UserType.merchant;
      case 'admin':
        return UserType.admin;
      case 'user':
      default:
        return UserType.user;
    }
  }
}
