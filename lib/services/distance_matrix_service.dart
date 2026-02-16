import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/config/env_config.dart';

class DistanceMatrixService {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/distancematrix/json';

  Future<List<double?>> getDrivingDistances({
    required LatLng origin,
    required List<LatLng> destinations,
  }) async {
    if (destinations.isEmpty) return [];

    final apiKey = EnvConfig.googleDirectionsApiKey;
    final destinationParam = destinations
        .map((d) => '${d.latitude},${d.longitude}')
        .join('|');

    final uri = Uri.parse(
      '$_baseUrl?origins=${origin.latitude},${origin.longitude}'
      '&destinations=$destinationParam'
      '&mode=driving'
      '&key=$apiKey',
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        return List<double?>.filled(destinations.length, null);
      }

      final data = json.decode(response.body);
      if (data['status'] != 'OK' ||
          data['rows'] == null ||
          data['rows'].isEmpty) {
        return List<double?>.filled(destinations.length, null);
      }

      final elements = data['rows'][0]['elements'] as List<dynamic>;
      final results = <double?>[];
      for (final element in elements) {
        if (element['status'] == 'OK') {
          final meters = element['distance']['value'] as num;
          results.add(meters.toDouble());
        } else {
          results.add(null);
        }
      }

      if (results.length < destinations.length) {
        results.addAll(
          List<double?>.filled(destinations.length - results.length, null),
        );
      }

      return results;
    } catch (_) {
      return List<double?>.filled(destinations.length, null);
    }
  }
}
