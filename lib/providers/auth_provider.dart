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
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance; // Assurer l'initialisation
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
    print('-----------------------------------------------------');
    print('[AuthProvider._fetchUserProfile] Fetching profile for UID: $uid');
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final role = data['role'] as String?;
        print('[AuthProvider._fetchUserProfile] Firestore role string: "$role"');
        _userType = _parseUserType(role);
        print('[AuthProvider._fetchUserProfile] Parsed UserType: $_userType');

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
    print('[AuthProvider.loginUnified] Attempting login for: $email');
    _setLoading(true);
    _error = null;
    // _userType = UserType.unknown; // Réinitialiser avant la tentative pourrait être envisagé
    // _clearProfiles(); // Effacer les profils avant la tentative

    try {
      print('[AuthProvider.loginUnified] Calling _authService.loginUnified...');
      final uid = await _authService.loginUnified(email, password);
      print('[AuthProvider.loginUnified] _authService.loginUnified returned UID: $uid');

      if (uid != null) {
        // Authentification Firebase réussie. Maintenant, récupérer explicitement le profil.
        // Il est possible que _listenToAuthChanges soit également déclenché.
        // Pour s'assurer que loginUnified attend la récupération du profil :

        // Mettre à jour _firebaseUser ici pour refléter l'utilisateur connecté
        // Cela suppose que _authService.loginUnified a mis à jour currentUser de FirebaseAuth.
        // Si _authService.authStateChanges est rapide, _firebaseUser pourrait déjà être mis à jour.
        // Pour être sûr, on peut re-vérifier :
        if (_firebaseAuth.currentUser != null && _firebaseAuth.currentUser!.uid == uid) {
          _firebaseUser = _firebaseAuth.currentUser;
          print('[AuthProvider.loginUnified] Firebase user confirmed: $uid. Fetching profile...');
          await _fetchUserProfile(uid); // Attendre la récupération du profil
          if (_userType != UserType.unknown) { // Si le profil a été trouvé et le rôle défini
            await _updateLastLogin(uid); // Mettre à jour la date de dernière connexion
          }
          print('[AuthProvider.loginUnified] Profile fetched. UserType: $_userType');
        } else {
          // Cas improbable où currentUser n'est pas (encore) à jour ou ne correspond pas.
          // Cela pourrait indiquer un problème de timing avec le stream authStateChanges.
          // On pourrait forcer une nouvelle récupération de l'utilisateur Firebase si nécessaire,
          // mais _fetchUserProfile(uid) devrait suffire si l'UID est correct.
          print('[AuthProvider.loginUnified] Firebase currentUser not immediately reflecting the new user or UID mismatch. Relying on uid: $uid for profile fetch.');
          // uid est garanti non-nul ici à cause du `if (uid != null)` externe.
          // L'utilisation de uid! rend cela explicite pour l'analyseur si nécessaire.
          await _fetchUserProfile(uid!);
           if (_userType != UserType.unknown) {
            await _updateLastLogin(uid!);
          }
          print('[AuthProvider.loginUnified] Profile fetched (after UID mismatch check). UserType: $_userType');
           // Si _firebaseUser n'est toujours pas défini, cela pourrait être un souci, mais _fetchUserProfile
           // ne dépend que de l'UID pour récupérer les données Firestore.
           // L'état _firebaseUser sera de toute façon mis à jour par _listenToAuthChanges.
        }
      } else {
        // Ce cas (uid est null mais pas d'exception) ne devrait pas se produire.
        _error = "Erreur de connexion: UID non retourné par AuthService.";
        _userType = UserType.unknown;
        _clearProfiles();
        print('[AuthProvider.loginUnified] AuthService returned null UID without exception. Error set.');
      }
    } catch (e) {
      print('[AuthProvider.loginUnified] Caught exception: ${e.toString()}');
      _error = e.toString();
      _userType = UserType.unknown;
      _clearProfiles();
      print('[AuthProvider.loginUnified] Exception caught. _error set to: $_error, _userType set to: $_userType');
    } finally {
      print('[AuthProvider.loginUnified] Finally block. Current _error: $_error, _userType: $_userType, isAuthenticated: $isAuthenticated, firebaseUser UID: ${_firebaseUser?.uid}');
      _setLoading(false); // Cela appellera notifyListeners()
      print('[AuthProvider.loginUnified] Login attempt finished. isLoading is now false.');
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
    required List<String> services, // Modifié de String à List<String>
    required String password,
    required double? latitude,
    required double? longitude,
    required String merchantType, // Ajouté
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
          'services': services, // Sauvegarder la liste des services
          'isVerified': false,
          'isActive': true,
          'lastLoginAt': FieldValue.serverTimestamp(),
          'latitude': latitude,
          'longitude': longitude,
          'merchantType': merchantType, // Sauvegarder le type de marchand
          // Ajouter ici d'autres champs spécifiques aux marchands si nécessaire
        }, SetOptions(merge: true));

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
    switch (role?.toLowerCase()) {
      case 'merchant':
        return UserType.merchant;
      case 'admin':
        return UserType.admin;
      case 'user':
        return UserType.user;
      default:
        return UserType.unknown;
    }
  }

  Future<bool> updateMerchantProfile({
    required String businessName,
    required String phone,
    required String address,
    required String openingHours,
    required List<String> services,
    required Map<String, String> serviceStockStatus,
    // Potentiellement d'autres champs comme latitude, longitude si modifiables
  }) async {
    _setLoading(true);
    _error = null;

    if (_firebaseUser == null || _userType != UserType.merchant) {
      _error = "Aucun marchand connecté pour la mise à jour.";
      _setLoading(false);
      return false;
    }
    final uid = _firebaseUser!.uid;

    Map<String, dynamic> dataToUpdate = {
      'name': businessName, // 'name' est utilisé pour businessName dans Firestore
      'phone': phone,
      'address': address,
      'openingHours': openingHours,
      'services': services,
      'serviceStockStatus': serviceStockStatus,
      'lastProfileUpdateAt': FieldValue.serverTimestamp(), // Pour tracer la mise à jour
    };

    try {
      await _firestore.collection('users').doc(uid).update(dataToUpdate);

      // Rafraîchir le profil localement
      // Option 1: Recharger depuis Firestore (plus sûr pour la cohérence)
      await _fetchUserProfile(uid);
      // Option 2: Mettre à jour le modèle local (plus rapide, mais attention à la synchro)
      // if (_merchantProfile != null) {
      //   _merchantProfile = _merchantProfile!.copyWith(
      //     businessName: businessName,
      //     phone: phone,
      //     address: address,
      //     openingHours: openingHours,
      //     services: services,
      //     serviceStockStatus: serviceStockStatus,
      //     // lastLoginAt ne change pas ici, createdAt non plus
      //   );
      // }

      _setLoading(false);
      notifyListeners(); // Notifier même si on recharge, car _fetchUserProfile notifie aussi.
      return true;
    } catch (e) {
      _error = "Erreur lors de la mise à jour du profil: ${e.toString()}";
      _setLoading(false);
      return false;
    }
  }
}
