import 'dart:async'; // Pour StreamSubscription
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as fb_auth; // Pour l'objet User de Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../features/merchant/models/merchant_auth_model.dart';
import '../features/admin/models/admin_model.dart';
import '../features/user/models/user_model.dart';
import '../services/auth_service.dart';

enum UserType { user, merchant, admin, unknown }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  StreamSubscription? _authStateSubscription;

  fb_auth.User? _firebaseUser;
  bool _isLoading = false;
  String? _error;
  UserType _userType = UserType.unknown;

  User? _appUserProfile;
  MerchantAuthModel? _merchantProfile;
  AdminModel? _adminProfile;

  bool get isAuthenticated =>
      _firebaseUser != null && _userType != UserType.unknown;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserType get userType => _userType;
  User? get appUserProfile => _appUserProfile;
  MerchantAuthModel? get merchantProfile => _merchantProfile;
  AdminModel? get adminProfile => _adminProfile;
  String? get userId => _firebaseUser?.uid;

  AuthProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authStateSubscription = _authService.authStateChanges.listen((
      fb_auth.User? user,
    ) async {
      _setLoading(true);
      _firebaseUser = user;
      if (_firebaseUser != null) {
        try {
          await _fetchUserProfile(_firebaseUser!.uid);
          if (_userType != UserType.unknown) {
            await _updateLastLogin(_firebaseUser!.uid);
          }
        } catch (e) {
          _error = "Erreur lors de la récupération du profil: ${e.toString()}";
          _userType = UserType.unknown;
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

        switch (_userType) {
          case UserType.admin:
            _adminProfile = AdminModel.fromFirestore(docSnapshot);
            _appUserProfile = null;
            _merchantProfile = null;
            break;
          case UserType.merchant:
            _merchantProfile = MerchantAuthModel.fromFirestore(docSnapshot);
            _appUserProfile = null;
            _adminProfile = null;
            break;
          case UserType.user:
            _appUserProfile = User.fromFirestore(
              docSnapshot as DocumentSnapshot<Map<String, dynamic>>,
            );
            _merchantProfile = null;
            _adminProfile = null;
            break;
          default:
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
      _error =
          "Erreur Firestore lors de la récupération du profil: ${e.toString()}";
      _userType = UserType.unknown;
      _clearProfiles();
      rethrow;
    }
  }

  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
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

  Future<void> loginUnified(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final uid = await _authService.loginUnified(email, password);
      if (uid != null) {
        // Mettre à jour _firebaseUser manuellement après la connexion réussie
        _firebaseUser = _firebaseAuth.currentUser;
        // Récupérer le profil utilisateur immédiatement
        await _fetchUserProfile(uid);
        if (_userType != UserType.unknown) {
          await _updateLastLogin(uid);
        } else {
          // Si le type d'utilisateur est inconnu après fetch, c'est une erreur de profil
          _error = "Impossible de déterminer le rôle de l'utilisateur.";
          _clearProfiles();
        }
      } else {
        // Cette partie est théoriquement redondante si AuthService lève toujours une exception
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
    }
  }

  Future<void> registerUser(String name, String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final uid = await _authService.registerUser(name, email, password);
      if (uid == null) {
        _error = "Erreur d'inscription: UID non retourné.";
        _userType = UserType.unknown;
        _clearProfiles();
      }
      // _listenToAuthChanges s'occupera de fetch le profil
    } catch (e) {
      _error = e.toString();
      _userType = UserType.unknown;
      _clearProfiles();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.logout();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    clearError();
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  Future<void> registerMerchant({
    required String businessName,
    required String email,
    required String phone,
    required String address,
    required Map<String, dynamic> openingHours,
    required List<String> services, // CHANGED to List<String>
    required String password,
    required double? latitude,
    required double? longitude,
    required String merchantType, // ADDED
    required String profileType, // NOUVEAU
  }) async {
    _setLoading(true);
    _error = null;

    print("[AuthProvider] Début de l'inscription marchand pour: $email");

    try {
      // Créer le compte Firebase Auth directement sans passer par AuthService
      print("[AuthProvider] Création du compte Firebase Auth...");
      final userCredential = await fb_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user?.uid;
      print("[AuthProvider] Compte Firebase Auth créé avec UID: $uid");

      if (uid != null) {
        // Créer directement le profil marchand dans Firestore
        print("[AuthProvider] Création du profil marchand dans Firestore...");
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'email': email,
          'name': businessName,
          'role': 'merchant', // Forcer le rôle marchand
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
        });

        print("[AuthProvider] Profil marchand créé avec succès dans Firestore");
      } else {
        _error = "Erreur lors de la création du compte marchand.";
        print(
          "[AuthProvider] Erreur: UID null après création du compte Firebase Auth",
        );
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      print("[AuthProvider] Erreur Firebase Auth lors de l'inscription marchand: ${e.code}");
      if (e.code == 'weak-password') {
        _error = 'Le mot de passe est trop faible.';
      } else if (e.code == 'email-already-in-use') {
        _error = 'Cette adresse e-mail est déjà utilisée.';
      } else {
        _error = 'Erreur d\'inscription: ${e.message}';
      }
    } catch (e) {
      _error = "Une erreur inconnue est survenue: ${e.toString()}";
      print("[AuthProvider] Erreur générique lors de l'inscription marchand: $e");
    } finally {
      _setLoading(false);
      print("[AuthProvider] Fin de l'inscription marchand. Erreur: $_error");
    }
  }

  Future<bool> updateMerchantProfile({
    required String businessName,
    required String phone,
    required String address,
    required Map<String, dynamic> openingHours,
    required List<String> services,
    required Map<String, String> serviceStockStatus,
    required List<String> imageUrls,
    XFile? profileImageFile,
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
      'name': businessName,
      'phone': phone,
      'address': address,
      'openingHours': openingHours,
      'services': services,
      'serviceStockStatus': serviceStockStatus,
      'imageUrls': imageUrls,
      'lastProfileUpdateAt': FieldValue.serverTimestamp(),
    };

    try {
      if (profileImageFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('merchant_profile_images')
            .child('$uid.jpg');
        // Compression légère pour accélérer l'upload et le chargement
        final compressed = await FlutterImageCompress.compressWithFile(
          profileImageFile.path,
          quality: 70,
        );
        if (compressed != null) {
          await ref.putData(compressed, SettableMetadata(contentType: 'image/jpeg'));
        } else {
          await ref.putFile(File(profileImageFile.path));
        }
        final imageUrl = await ref.getDownloadURL();
        dataToUpdate['profileImageUrl'] = imageUrl;
      }

      await _firestore.collection('users').doc(uid).update(dataToUpdate);
      await _fetchUserProfile(uid); // Recharger pour la cohérence

      _setLoading(false);
      // notifyListeners(); // _fetchUserProfile ou _setLoading le fait déjà
      return true;
    } catch (e) {
      _error = "Erreur lors de la mise à jour du profil: ${e.toString()}";
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateUserProfile({
    required String name,
    String? phone,
    XFile? imageFile,
  }) async {
    _setLoading(true);
    _error = null;

    if (_firebaseUser == null || _userType != UserType.user) {
      _error = "Aucun utilisateur connecté pour la mise à jour.";
      _setLoading(false);
      return false;
    }
    final uid = _firebaseUser!.uid;

    Map<String, dynamic> dataToUpdate = {'name': name, 'phone': phone};

    try {
      if (imageFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_profile_images')
            .child('$uid.jpg');
        final compressed2 = await FlutterImageCompress.compressWithFile(
          imageFile.path,
          quality: 70,
        );
        if (compressed2 != null) {
          await ref.putData(compressed2, SettableMetadata(contentType: 'image/jpeg'));
        } else {
          await ref.putFile(File(imageFile.path));
        }
        final imageUrl = await ref.getDownloadURL();
        dataToUpdate['profileImageUrl'] = imageUrl;
      }

      await _firestore.collection('users').doc(uid).update(dataToUpdate);
      await _fetchUserProfile(uid); // Recharger pour la cohérence
      _setLoading(false);
      return true;
    } catch (e) {
      _error = "Erreur lors de la mise à jour du profil: ${e.toString()}";
      _setLoading(false);
      return false;
    }
  }

  Future<void> updateUserToPremium() async {
    _setLoading(true);
    _error = null;

    if (_firebaseUser == null) {
      _error = "Aucun utilisateur connecté pour la mise à jour.";
      _setLoading(false);
      return;
    }
    final uid = _firebaseUser!.uid;

    try {
      await _firestore.collection('users').doc(uid).update({
        'isPremium': true,
        'premiumSince': FieldValue.serverTimestamp(),
      });
      await _fetchUserProfile(uid); // Recharger pour la cohérence
    } catch (e) {
      _error = "Erreur lors du passage au statut premium: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }

  UserType _parseUserType(String? role) {
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
}
