import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../features/merchant/models/merchant_auth_model.dart';
import '../features/admin/models/admin_model.dart';
import '../features/user/models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/auth_exception.dart';

enum UserType { user, merchant, admin, unknown }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
        await _tryFetchUserProfile(_firebaseUser!.uid);
      } else {
        _userType = UserType.unknown;
        _clearProfiles();
      }
      _setLoading(false);
    });
  }

  Future<void> _tryFetchUserProfile(String uid) async {
    try {
      await _fetchUserProfile(uid);
      if (_userType != UserType.unknown) {
        await _updateLastLogin(uid);
      }
    } catch (e) {
      _setError("Erreur lors de la récupération du profil: ${e.toString()}");
    }
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final role = data['role'] as String?;
        _userType = _parseUserType(role);

        _clearProfiles();
        switch (_userType) {
          case UserType.admin:
            _adminProfile = AdminModel.fromFirestore(docSnapshot);
            break;
          case UserType.merchant:
            _merchantProfile = MerchantAuthModel.fromFirestore(docSnapshot);
            break;
          case UserType.user:
            _appUserProfile = User.fromFirestore(
              docSnapshot as DocumentSnapshot<Map<String, dynamic>>,
            );
            break;
          default:
            _setError("Rôle utilisateur non reconnu: $role");
        }
      } else {
        _setError("Profil utilisateur non trouvé dans Firestore.");
      }
    } catch (e) {
      _setError("Erreur Firestore lors de la récupération du profil: ${e.toString()}");
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
    _userType = UserType.unknown;
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> loginUnified(String email, String password) async {
    await _executeAuthAction(() async {
      final uid = await _authService.loginUnified(email, password);
      if (uid != null) {
        // L'écouteur `_listenToAuthChanges` s'occupera du reste.
      }
    });
  }

  Future<void> registerUser(String name, String email, String password) async {
    await _executeAuthAction(() async {
      await _authService.registerUser(name, email, password);
      // L'écouteur `_listenToAuthChanges` s'occupera du reste.
    });
  }

  Future<void> logout() async {
    await _executeAuthAction(() async {
      await _authService.logout();
    });
  }

  Future<void> resetPassword(String email) async {
    await _executeAuthAction(() async {
      await _authService.resetPassword(email);
    });
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
  }) async {
    await _executeAuthAction(() async {
      await _userService.registerMerchant(
        businessName: businessName,
        email: email,
        phone: phone,
        address: address,
        openingHours: openingHours,
        services: services,
        password: password,
        latitude: latitude,
        longitude: longitude,
        merchantType: merchantType,
        profileType: profileType,
      );
    });
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    XFile? imageFile,
    String? businessName,
    String? address,
    Map<String, dynamic>? openingHours,
    List<String>? services,
    Map<String, String>? serviceStockStatus,
    List<String>? imageUrls,
  }) async {
    if (_firebaseUser == null) {
      _setError("Aucun utilisateur connecté pour la mise à jour.");
      return false;
    }

    bool result = false;
    await _executeAuthAction(() async {
      final uid = _firebaseUser!.uid;
      Map<String, dynamic> dataToUpdate = {};

      if (_userType == UserType.user) {
        dataToUpdate = {'name': name, 'phone': phone};
      } else if (_userType == UserType.merchant) {
        dataToUpdate = {
          'name': businessName,
          'phone': phone,
          'address': address,
          'openingHours': openingHours,
          'services': services,
          'serviceStockStatus': serviceStockStatus,
          'imageUrls': imageUrls,
          'lastProfileUpdateAt': FieldValue.serverTimestamp(),
        };
      }

      if (imageFile != null) {
        final imageUrl = await _uploadImage(imageFile, uid);
        dataToUpdate['profileImageUrl'] = imageUrl;
      }

      await _firestore.collection('users').doc(uid).update(dataToUpdate);
      await _fetchUserProfile(uid);
      result = true;
    });
    return result;
  }

  Future<String> _uploadImage(XFile imageFile, String uid) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('${_userType.name}_profile_images')
        .child('$uid.jpg');
    await ref.putFile(File(imageFile.path));
    return await ref.getDownloadURL();
  }

  Future<void> _executeAuthAction(AsyncCallback action) async {
    _setLoading(true);
    _error = null;
    try {
      await action();
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setError(String message) {
    _error = message;
    _userType = UserType.unknown;
    _clearProfiles();
    notifyListeners();
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
