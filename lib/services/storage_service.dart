import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImage(XFile image, String merchantId) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(image.path)}';
      final Reference ref = _storage.ref().child('merchants/$merchantId/$fileName');
      final UploadTask uploadTask = ref.putFile(File(image.path));
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Erreur lors de l'upload de l'image: $e");
      return null;
    }
  }

  Future<String?> uploadProfilePicture(File image, String userId) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(image.path)}';
      final Reference ref =
          _storage.ref().child('users/$userId/profile/$fileName');
      final UploadTask uploadTask = ref.putFile(image);
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Erreur lors de l'upload de la photo de profil: $e");
      return null;
    }
  }

  static const String _tokenKey = 'auth_token';
  static const String _userTypeKey = 'user_type';
  static const String _userDataKey = 'user_data';
  static const String _merchantDataKey = 'merchant_data';
  static const String _adminDataKey = 'admin_data';
  static const String _settingsKey = 'app_settings';
  static const String _lastLocationKey = 'last_location';

  // Sauvegarder le token d'authentification
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Récupérer le token d'authentification
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Supprimer le token
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Sauvegarder le type d'utilisateur
  Future<void> saveUserType(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTypeKey, userType);
  }

  // Récupérer le type d'utilisateur
  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }

  // Sauvegarder les données utilisateur
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, json.encode(userData));
  }

  // Récupérer les données utilisateur
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userDataKey);
    if (data != null) {
      return json.decode(data) as Map<String, dynamic>;
    }
    return null;
  }

  // Sauvegarder les données marchand
  Future<void> saveMerchantData(Map<String, dynamic> merchantData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_merchantDataKey, json.encode(merchantData));
  }

  // Récupérer les données marchand
  Future<Map<String, dynamic>?> getMerchantData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_merchantDataKey);
    if (data != null) {
      return json.decode(data) as Map<String, dynamic>;
    }
    return null;
  }

  // Sauvegarder les données admin
  Future<void> saveAdminData(Map<String, dynamic> adminData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_adminDataKey, json.encode(adminData));
  }

  // Récupérer les données admin
  Future<Map<String, dynamic>?> getAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_adminDataKey);
    if (data != null) {
      return json.decode(data) as Map<String, dynamic>;
    }
    return null;
  }

  // Sauvegarder les paramètres de l'application
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, json.encode(settings));
  }

  // Récupérer les paramètres de l'application
  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_settingsKey);
    if (data != null) {
      return json.decode(data) as Map<String, dynamic>;
    }
    return {};
  }

  // Sauvegarder la dernière position connue
  Future<void> saveLastLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    final locationData = {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_lastLocationKey, json.encode(locationData));
  }

  // Récupérer la dernière position connue
  Future<Map<String, dynamic>?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_lastLocationKey);
    if (data != null) {
      return json.decode(data) as Map<String, dynamic>;
    }
    return null;
  }

  // Sauvegarder une valeur simple
  Future<void> saveValue(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    }
  }

  // Récupérer une valeur simple
  Future<T?> getValue<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (T == String) {
      return prefs.getString(key) as T?;
    } else if (T == int) {
      return prefs.getInt(key) as T?;
    } else if (T == double) {
      return prefs.getDouble(key) as T?;
    } else if (T == bool) {
      return prefs.getBool(key) as T?;
    } else if (T == List<String>) {
      return prefs.getStringList(key) as T?;
    }
    return null;
  }

  // Supprimer une valeur
  Future<void> removeValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Vérifier si une clé existe
  Future<bool> hasKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  // Obtenir toutes les clés
  Future<Set<String>> getAllKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys();
  }

  // Nettoyer toutes les données
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Nettoyer les données d'authentification
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userTypeKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_merchantDataKey);
    await prefs.remove(_adminDataKey);
  }

  // Sauvegarder des données complexes
  Future<void> saveComplexData(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(data));
  }

  // Récupérer des données complexes
  Future<Map<String, dynamic>?> getComplexData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    if (data != null) {
      return json.decode(data) as Map<String, dynamic>;
    }
    return null;
  }

  // Sauvegarder une liste d'objets
  Future<void> saveList<T>(
    String key,
    List<T> list,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((item) => item as Map<String, dynamic>).toList();
    await prefs.setString(key, json.encode(jsonList));
  }

  // Récupérer une liste d'objets
  Future<List<T>> getList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    if (data != null) {
      final jsonList = json.decode(data) as List;
      return jsonList
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
