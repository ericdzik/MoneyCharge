import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/config/env_config.dart';
import '../core/utils/logger.dart';

/// Service pour gérer les directions Google Maps
/// Utilise la clé API depuis les variables d'environnement
class DirectionsService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';

  /// Récupère les directions entre deux points
  Future<Map<String, dynamic>?> getDirections(
    LatLng origin,
    LatLng destination, {
    String travelMode = 'driving', // driving, walking, bicycling, transit
  }) async {
    // Récupération sécurisée de la clé API depuis EnvConfig
    final apiKey = EnvConfig.googleDirectionsApiKey;

    final Uri uri = Uri.parse(
      '$_baseUrl?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=$travelMode&key=$apiKey',
    );

    AppLogger.debug('[DirectionsService] Requesting directions: origin=$origin, destination=$destination, mode=$travelMode');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];

          return {
            'polyline_encoded': route['overview_polyline']['points'] as String,
            'distance_text': leg['distance']['text'] as String,
            'duration_text': leg['duration']['text'] as String,
            'bounds_ne': LatLng(
              route['bounds']['northeast']['lat'] as double,
              route['bounds']['northeast']['lng'] as double,
            ),
            'bounds_sw': LatLng(
              route['bounds']['southwest']['lat'] as double,
              route['bounds']['southwest']['lng'] as double,
            ),
          };
        } else {
          AppLogger.error('[DirectionsService] Error from API: ${data['status']} - ${data['error_message']}');
          return null; // ou lancer une exception spécifique
        }
      } else {
        AppLogger.error('[DirectionsService] HTTP Error: ${response.statusCode} - ${response.body}');
        return null; // ou lancer une exception spécifique
      }
    } catch (e) {
      AppLogger.error('[DirectionsService] Exception occurred', e);
      return null; // ou lancer une exception spécifique
    }
  }
}
