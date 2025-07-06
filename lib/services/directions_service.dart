import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Pour LatLng
// import 'package:flutter_polyline_points/flutter_polyline_points.dart'; // Sera utilisé dans le Provider

// TODO: Remplacez CECI par votre véritable clé API Google Directions.
// Idéalement, chargez-la depuis un fichier de configuration sécurisé ou des variables d'environnement.
const String _googleApiKey = 'AIzaSyDAHK3ivuTDoxHj0hTp5rkTQxPojkj8FSU';

class DirectionsService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';

  Future<Map<String, dynamic>?> getDirections(
    LatLng origin,
    LatLng destination, {
    String travelMode = 'driving', // driving, walking, bicycling, transit
  }) async {
    if (_googleApiKey == 'AIzaSyDAHK3ivuTDoxHj0hTp5rkTQxPojkj8FSU') {
      print('ERREUR: Veuillez remplacer VOTRE_CLE_API_GOOGLE_DIRECTIONS_ICI dans directions_service.dart');
      // Vous pourriez retourner une erreur spécifique ou null pour indiquer le problème de clé API
      // throw Exception('Clé API Google Directions non configurée.');
      return null;
    }

    final Uri uri = Uri.parse(
      '$_baseUrl?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=$travelMode&key=$_googleApiKey',
    );

    print('[DirectionsService] Requesting directions: ${uri.toString()}');

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
          print('[DirectionsService] Error from API: ${data['status']} - ${data['error_message']}');
          return null; // ou lancer une exception spécifique
        }
      } else {
        print('[DirectionsService] HTTP Error: ${response.statusCode} - ${response.body}');
        return null; // ou lancer une exception spécifique
      }
    } catch (e) {
      print('[DirectionsService] Exception occurred: $e');
      return null; // ou lancer une exception spécifique
    }
  }
}
