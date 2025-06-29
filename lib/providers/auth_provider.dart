import 'dart:async'; // Pour StreamSubscription
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Pour l'objet User de Firebase
// cloud_firestore est déjà importé ici, mais vérifions qu'il n'y a pas de redondance ou de mauvaise place
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/merchant/models/merchant_auth_model.dart';
import '../features/admin/models/admin_model.dart';
import '../services/auth_service.dart';

// L'enum UserType peut rester, il sera mappé depuis le rôle String de Firestore
enum UserType { user, merchant, admin, unknown }

class User {
  final String id; // Corresponds à l'UID de Firebase Auth
  final String name;
  final String email;
  final String? phone;
  final DateTime? createdAt; // Peut être null si le timestamp n'est pas encore écrit
  final DateTime? lastLoginAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.createdAt,
    this.lastLoginAt,
  });

  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return User(
      id: snapshot.id, // Utiliser l'ID du document (qui est l'UID)
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _authStateSubscription;

  // État d'authentification
  fb_auth.User? _firebaseUser; // Utilisateur Firebase Auth
  bool _isLoading = false;
  String? _error;
  UserType _userType = UserType.unknown; // Initialisé à unknown

  // Données de profil de l'application (venant de Firestore)
  User? _appUserProfile; // Pour le rôle 'user'
  MerchantAuthModel? _merchantProfile; // Pour le rôle 'merchant'
  AdminModel? _adminProfile; // Pour le rôle 'admin'

  // Getters
  bool get isAuthenticated => _firebaseUser != null && _userType != UserType.unknown;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserType get userType => _userType;

  // Getters pour les profils spécifiques. L'UI devra vérifier le userType avant d'y accéder.
  User? get appUserProfile => _appUserProfile;
  MerchantAuthModel? get merchantProfile => _merchantProfile;
  AdminModel? get adminProfile => _adminProfile;
  String? get userId => _firebaseUser?.uid;


  AuthProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authStateSubscription = _authService.authStateChanges.listen((fb_auth.User? user) async {
      _setLoading(true);
      _firebaseUser = user;
      if (_firebaseUser != null) {
        try {
          await _fetchUserProfile(_firebaseUser!.uid);
          if (_userType != UserType.unknown) { // Si le profil a été trouvé et le rôle défini
            await _updateLastLogin(_firebaseUser!.uid);
          }
        } catch (e) {
          _error = "Erreur lors de la récupération du profil: ${e.toString()}";
          _userType = UserType.unknown; // Marquer comme inconnu si le profil n'est pas trouvé
          _clearProfiles();
        }
      } else {
        _userType = UserType.unknown;
        _clearProfiles();
      }
      _setLoading(false);
    });
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final role = data['role'] as String?;
        _userType = _parseUserType(role);

        // Créer l'objet profil approprié
        switch (_userType) {
          case UserType.admin:
            _adminProfile = AdminModel.fromFirestore(docSnapshot); // Supposant une méthode factory
            _appUserProfile = null;
            _merchantProfile = null;
            break;
          case UserType.merchant:
            _merchantProfile = MerchantAuthModel.fromFirestore(docSnapshot); // Supposant une méthode factory
            _appUserProfile = null;
            _adminProfile = null;
            break;
          case UserType.user:
            _appUserProfile = User.fromFirestore(docSnapshot); // Supposant une méthode factory
            _merchantProfile = null;
            _adminProfile = null;
            break;
          default: // unknown ou rôle non géré
             _error = "Rôle utilisateur non reconnu: $role";
            _clearProfiles();
            _userType = UserType.unknown;
        }
      } else {
        _error = "Profil utilisateur non trouvé dans Firestore.";
        _userType = UserType.unknown;
        _clearProfiles();
      }
    } catch (e) {
      _error = "Erreur Firestore lors de la récupération du profil: ${e.toString()}";
      _userType = UserType.unknown;
      _clearProfiles();
      rethrow; // Pour que l'appelant puisse aussi gérer l'erreur
    }
  }

  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Erreur non critique, on peut la logger mais ne pas bloquer l'utilisateur
      print("Erreur lors de la mise à jour de lastLoginAt: $e");
    }
  }

  void _clearProfiles() {
    _appUserProfile = null;
    _merchantProfile = null;
    _adminProfile = null;
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  // Connexion unifiée
  Future<void> loginUnified(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final uid = await _authService.loginUnified(email, password);
      if (uid != null) {
        // _listenToAuthChanges devrait s'en occuper, mais forcer une récupération ici
        // peut rendre l'UI plus réactive si authStateChanges a un léger délai.
        // Alternativement, on peut juste attendre que _listenToAuthChanges mette à jour l'état.
        // Pour l'instant, on laisse _listenToAuthChanges gérer la mise à jour du profil.
        // Si _firebaseUser est déjà mis à jour par le stream, _fetchUserProfile et _updateLastLogin
        // auront déjà été appelés par _listenToAuthChanges.
      } else {
        // Ce cas ne devrait pas arriver si loginUnified lève une exception en cas d'échec
         _error = "Erreur de connexion: UID non retourné.";
         _userType = UserType.unknown;
        _clearProfiles();
      }
    } catch (e) {
      _error = e.toString();
      _userType = UserType.unknown;
      _clearProfiles();
    } finally {
      _setLoading(false);
      // notifyListeners() est appelé par _setLoading et par _listenToAuthChanges
    }
  }

  // Inscription utilisateur
  Future<void> registerUser(String name, String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      // AuthService.registerUser s'occupe de créer l'utilisateur dans Auth ET son profil dans Firestore.
      final uid = await _authService.registerUser(name, email, password);
      if (uid != null) {
        // Comme pour login, on se fie à _listenToAuthChanges pour peupler le profil.
        // L'utilisateur sera automatiquement connecté après l'inscription.
      } else {
         _error = "Erreur d'inscription: UID non retourné.";
         _userType = UserType.unknown;
        _clearProfiles();
      }
    } catch (e) {
      _error = e.toString();
      _userType = UserType.unknown;
      _clearProfiles();
    } finally {
      _setLoading(false);
    }
  }

  // Déconnexion
  Future<void> logout() async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.logout();
      // _listenToAuthChanges mettra à jour _firebaseUser à null,
      // ce qui nettoiera les profils et mettra _userType à unknown.
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    _setLoading(true);
    clearError(); // Utiliser la nouvelle méthode pour clearer l'erreur
    try {
      await _authService.resetPassword(email);
      // Peut-être afficher un message de succès à l'utilisateur via un autre mécanisme
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners(); // Notifier si l'erreur est effectivement clearée
    }
  }

  // Méthode de debug pour forcer la connexion admin - À SUPPRIMER ou adapter pour Firebase
  // La méthode forceAdminLogin() est supprimée.

  // L'ancienne méthode checkAuthStatus est remplacée par _listenToAuthChanges.
  // L'ancienne méthode initialize est remplacée par le constructeur qui appelle _listenToAuthChanges.

  // Inscription marchand avec informations complètes - À REVOIR pour Firebase
  // Cette méthode devra créer un utilisateur Auth, puis un document marchand dans Firestore.
  Future<void> registerMerchant({
    required String businessName,
    required String email,
    required String phone,
    required String address,
    required String openingHours,
    required String services,
    required String password,
    // Add new parameters for location
    required double? latitude,
    required double? longitude,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      // 1. Créer l'utilisateur dans Firebase Auth
      final uid = await _authService.registerUser(businessName, email, password); // Utilise businessName comme 'name' pour l'instant

      if (uid != null) {
        // 2. Créer/Mettre à jour le document utilisateur dans Firestore avec le rôle 'merchant'
        // et les informations spécifiques au marchand.
        // Cela pourrait être une méthode dans AuthService ou directement ici.
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'email': email,
          'name': businessName, // ou un champ 'contactName' et 'businessName' séparé
          'role': 'merchant', // Définir explicitement le rôle
          'createdAt': FieldValue.serverTimestamp(),
          'phone': phone,
          'address': address,
          'openingHours': openingHours,
          'services': services,
          'isVerified': false, // Les marchands commencent comme non vérifiés
          'isActive': true,
          'lastLoginAt': FieldValue.serverTimestamp(),
          'latitude': latitude, // Add latitude to Firestore data
          'longitude': longitude, // Add longitude to Firestore data
          // Ajouter ici d'autres champs spécifiques aux marchands si nécessaire
        }, SetOptions(merge: true)); // merge: true pour ne pas écraser d'autres champs si le doc existe déjà (peu probable ici)

        // L'état sera mis à jour par _listenToAuthChanges
      } else {
        _error = "Erreur lors de la création du compte marchand.";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Méthodes privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  UserType _parseUserType(String? role) { // Prend maintenant un String?
    switch (role?.toLowerCase()) { // Utilise null-safe operator
      case 'merchant':
        return UserType.merchant;
      case 'admin':
        return UserType.admin;
      case 'user':
        return UserType.user;
      default:
        return UserType.unknown; // Renvoyer unknown si rôle null ou non reconnu
    }
  }
}
