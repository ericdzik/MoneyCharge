import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de cache pour optimiser les performances
class CacheService {
  static const String _cachePrefix = 'cache_';
  static const String _timestampPrefix = 'timestamp_';

  // Durées de cache par défaut
  static const Duration _defaultCacheDuration = Duration(minutes: 15);
  static const Duration _merchantCacheDuration = Duration(minutes: 30);
  static const Duration _userCacheDuration = Duration(hours: 1);
  static const Duration _configCacheDuration = Duration(hours: 24);

  /// Sauvegarder des données en cache
  static Future<void> setData(
    String key,
    dynamic data, {
    Duration? duration,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_timestampPrefix$key';

      final jsonData = json.encode(data);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final cacheDuration = duration ?? _defaultCacheDuration;
      final expiryTime = timestamp + cacheDuration.inMilliseconds;

      await prefs.setString(cacheKey, jsonData);
      await prefs.setInt(timestampKey, expiryTime);
    } catch (e) {
      // En cas d'erreur, on continue sans cache
      print('Cache error: $e');
    }
  }

  /// Récupérer des données du cache
  static Future<T?> getData<T>(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_timestampPrefix$key';

      // Vérifier si les données existent
      if (!prefs.containsKey(cacheKey)) {
        return null;
      }

      // Vérifier si le cache n'est pas expiré
      final expiryTime = prefs.getInt(timestampKey) ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      if (currentTime > expiryTime) {
        // Cache expiré, supprimer les données
        await prefs.remove(cacheKey);
        await prefs.remove(timestampKey);
        return null;
      }

      // Récupérer et décoder les données
      final jsonData = prefs.getString(cacheKey);
      if (jsonData != null) {
        return json.decode(jsonData) as T;
      }

      return null;
    } catch (e) {
      print('Cache retrieval error: $e');
      return null;
    }
  }

  /// Vérifier si des données sont en cache et valides
  static Future<bool> hasValidCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_timestampPrefix$key';

      if (!prefs.containsKey(cacheKey)) {
        return false;
      }

      final expiryTime = prefs.getInt(timestampKey) ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      return currentTime <= expiryTime;
    } catch (e) {
      return false;
    }
  }

  /// Supprimer des données du cache
  static Future<void> removeData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_timestampPrefix$key';

      await prefs.remove(cacheKey);
      await prefs.remove(timestampKey);
    } catch (e) {
      print('Cache removal error: $e');
    }
  }

  /// Vider tout le cache
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_cachePrefix) || key.startsWith(_timestampPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Cache clear error: $e');
    }
  }

  /// Méthodes spécialisées pour différents types de données

  /// Cache des marchands
  static Future<void> cacheMerchants(List<dynamic> merchants) async {
    await setData('merchants', merchants, duration: _merchantCacheDuration);
  }

  static Future<List<dynamic>?> getCachedMerchants() async {
    return await getData<List<dynamic>>('merchants');
  }

  /// Cache des données utilisateur
  static Future<void> cacheUserData(Map<String, dynamic> userData) async {
    await setData('user_data', userData, duration: _userCacheDuration);
  }

  static Future<Map<String, dynamic>?> getCachedUserData() async {
    return await getData<Map<String, dynamic>>('user_data');
  }

  /// Cache de la configuration
  static Future<void> cacheConfig(Map<String, dynamic> config) async {
    await setData('app_config', config, duration: _configCacheDuration);
  }

  static Future<Map<String, dynamic>?> getCachedConfig() async {
    return await getData<Map<String, dynamic>>('app_config');
  }

  /// Cache des transactions
  static Future<void> cacheTransactions(List<dynamic> transactions) async {
    await setData(
      'transactions',
      transactions,
      duration: _defaultCacheDuration,
    );
  }

  static Future<List<dynamic>?> getCachedTransactions() async {
    return await getData<List<dynamic>>('transactions');
  }

  /// Obtenir la taille du cache (pour debug)
  static Future<int> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      int size = 0;

      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          final data = prefs.getString(key);
          if (data != null) {
            size += data.length;
          }
        }
      }

      return size;
    } catch (e) {
      return 0;
    }
  }

  /// Obtenir les statistiques du cache
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      int cacheEntries = 0;
      int expiredEntries = 0;

      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          cacheEntries++;

          final timestampKey = key.replaceFirst(_cachePrefix, _timestampPrefix);
          final expiryTime = prefs.getInt(timestampKey) ?? 0;
          final currentTime = DateTime.now().millisecondsSinceEpoch;

          if (currentTime > expiryTime) {
            expiredEntries++;
          }
        }
      }

      return {
        'total_entries': cacheEntries,
        'expired_entries': expiredEntries,
        'valid_entries': cacheEntries - expiredEntries,
        'cache_size_bytes': await getCacheSize(),
      };
    } catch (e) {
      return {
        'total_entries': 0,
        'expired_entries': 0,
        'valid_entries': 0,
        'cache_size_bytes': 0,
      };
    }
  }
}
