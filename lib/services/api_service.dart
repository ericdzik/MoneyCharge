import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../features/user/models/merchant_model.dart';
import '../features/user/models/review_model.dart';
import 'cache_service.dart';
import '../core/utils/error_handler.dart';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String baseUrl = 'https://api.locacharge.com/v1';
  static const Duration _timeout = Duration(seconds: 30);

  // Méthodes génériques HTTP avec gestion d'erreurs
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    bool useCache = true,
  }) async {
    try {
      // Vérifier le cache si activé
      if (useCache) {
        final cachedData = await CacheService.getData<Map<String, dynamic>>(
          endpoint,
        );
        if (cachedData != null) {
          return cachedData;
        }
      }

      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(uri, headers: headers).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Mettre en cache si activé
        if (useCache) {
          await CacheService.setData(endpoint, data);
        }

        return data;
      } else {
        throw _handleHttpError(response.statusCode, response.body);
      }
    } catch (e) {
      ErrorHandler.logError(e, context: 'API GET $endpoint');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json', ...?headers},
            body: json.encode(data),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw _handleHttpError(response.statusCode, response.body);
      }
    } catch (e) {
      ErrorHandler.logError(e, context: 'API POST $endpoint');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .put(
            uri,
            headers: {'Content-Type': 'application/json', ...?headers},
            body: json.encode(data),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw _handleHttpError(response.statusCode, response.body);
      }
    } catch (e) {
      ErrorHandler.logError(e, context: 'API PUT $endpoint');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .delete(uri, headers: headers)
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return json.decode(response.body);
      } else {
        throw _handleHttpError(response.statusCode, response.body);
      }
    } catch (e) {
      ErrorHandler.logError(e, context: 'API DELETE $endpoint');
      rethrow;
    }
  }

  /// Gérer les erreurs HTTP
  Exception _handleHttpError(int statusCode, String body) {
    switch (statusCode) {
      case 400:
        return Exception('Requête invalide: $body');
      case 401:
        return Exception('Non autorisé. Veuillez vous reconnecter.');
      case 403:
        return Exception('Accès interdit.');
      case 404:
        return Exception('Ressource non trouvée.');
      case 500:
        return Exception('Erreur serveur interne.');
      case 502:
        return Exception('Serveur temporairement indisponible.');
      case 503:
        return Exception('Service temporairement indisponible.');
      default:
        return Exception('Erreur HTTP $statusCode: $body');
    }
  }

  // Méthodes spécifiques existantes avec améliorations
  Future<List<Merchant>> getMerchants({
    double? latitude,
    double? longitude,
    double? radius,
    bool useCache = true,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['lat'] = latitude.toString();
      if (longitude != null) queryParams['lng'] = longitude.toString();
      if (radius != null) queryParams['radius'] = radius.toString();

      final uri = Uri.parse(
        '$baseUrl/merchants',
      ).replace(queryParameters: queryParams);
      final cacheKey = 'merchants_${uri.query}';

      // Vérifier le cache
      if (useCache) {
        final cachedData = await CacheService.getCachedMerchants();
        if (cachedData != null) {
          return cachedData.map((json) => Merchant.fromJson(json)).toList();
        }
      }

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final merchants = (data['merchants'] as List)
            .map((json) => Merchant.fromJson(json))
            .toList();

        // Mettre en cache
        if (useCache) {
          await CacheService.cacheMerchants(data['merchants']);
        }

        return merchants;
      } else {
        throw _handleHttpError(response.statusCode, response.body);
      }
    } catch (e) {
      ErrorHandler.logError(e, context: 'getMerchants');
      rethrow;
    }
  }

  Future<Merchant> getMerchantById(String id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/merchants/$id'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Merchant.fromJson(data);
      } else {
        throw _handleHttpError(response.statusCode, response.body);
      }
    } catch (e) {
      ErrorHandler.logError(e, context: 'getMerchantById $id');
      rethrow;
    }
  }

  /// Nouvelles méthodes pour les transactions
  Future<List<Map<String, dynamic>>> getTransactions({
    String? merchantId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (merchantId != null) queryParams['merchant_id'] = merchantId;
      if (userId != null) queryParams['user_id'] = userId;
      if (startDate != null)
        queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final uri = Uri.parse(
        '$baseUrl/transactions',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final transactions = List<Map<String, dynamic>>.from(
          data['transactions'],
        );

        // Mettre en cache
        await CacheService.cacheTransactions(transactions);

        return transactions;
      } else {
        throw _handleHttpError(response.statusCode, response.body);
      }
    } catch (e) {
      ErrorHandler.logError(e, context: 'getTransactions');
      rethrow;
    }
  }

  /// Méthode pour créer une transaction
  Future<Map<String, dynamic>> createTransaction(
    Map<String, dynamic> transactionData,
  ) async {
    try {
      final response = await post('/transactions', transactionData);

      // Invalider le cache des transactions
      await CacheService.removeData('transactions');

      return response;
    } catch (e) {
      ErrorHandler.logError(e, context: 'createTransaction');
      rethrow;
    }
  }

  /// Méthode pour obtenir les statistiques
  Future<Map<String, dynamic>> getStats({
    String? merchantId,
    String? period,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (merchantId != null) queryParams['merchant_id'] = merchantId;
      if (period != null) queryParams['period'] = period;

      final uri = Uri.parse(
        '$baseUrl/stats',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw _handleHttpError(response.statusCode, response.body);
      }
    } catch (e) {
      ErrorHandler.logError(e, context: 'getStats');
      rethrow;
    }
  }

  Future<void> addReview(String merchantId, Review review) async {
    final merchantRef = _firestore.collection('users').doc(merchantId);
    final reviewRef = merchantRef.collection('reviews').doc();

    return _firestore.runTransaction((transaction) async {
      final merchantSnapshot = await transaction.get(merchantRef);
      if (!merchantSnapshot.exists) {
        throw Exception("Le marchand n'existe pas !");
      }

      final newReviewCount = (merchantSnapshot.data()!['reviewCount'] ?? 0) + 1;
      final oldRatingTotal = (merchantSnapshot.data()!['averageRating'] ?? 0.0) * (newReviewCount - 1);
      final newAverageRating = (oldRatingTotal + review.rating) / newReviewCount;

      transaction.set(reviewRef, review.toFirestore());
      transaction.update(merchantRef, {
        'averageRating': newAverageRating,
        'reviewCount': newReviewCount,
      });
    });
  }
}
