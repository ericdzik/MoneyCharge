import 'dart:io' show Platform;
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService {
  // Vérifier les permissions de localisation
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Demander les permissions de localisation
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Obtenir la position actuelle
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
  }

  // Vérifier si la localisation est activée
  Future<bool> isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Demander l'activation de la localisation
  Future<void> requestLocationService() async {
    await Geolocator.openLocationSettings();
  }

  // Calculer la distance entre deux points
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Obtenir la distance et le bearing entre deux points
  Map<String, double> getDistanceAndBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final distance = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    final bearing = Geolocator.bearingBetween(lat1, lon1, lat2, lon2);

    return {'distance': distance, 'bearing': bearing};
  }

  // Écouter les changements de position
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Mettre à jour tous les 10 mètres
      ),
    );
  }

  // Obtenir la dernière position connue
  Future<Position?> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition();
  }

  // Vérifier si une position est dans un rayon donné
  bool isWithinRadius(
    double centerLat,
    double centerLon,
    double targetLat,
    double targetLon,
    double radiusInMeters,
  ) {
    final distance = calculateDistance(
      centerLat,
      centerLon,
      targetLat,
      targetLon,
    );
    return distance <= radiusInMeters;
  }

  // Formater la distance en texte lisible
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  // Formater le bearing en direction
  String formatBearing(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) return 'Nord';
    if (bearing >= 22.5 && bearing < 67.5) return 'Nord-Est';
    if (bearing >= 67.5 && bearing < 112.5) return 'Est';
    if (bearing >= 112.5 && bearing < 157.5) return 'Sud-Est';
    if (bearing >= 157.5 && bearing < 202.5) return 'Sud';
    if (bearing >= 202.5 && bearing < 247.5) return 'Sud-Ouest';
    if (bearing >= 247.5 && bearing < 292.5) return 'Ouest';
    if (bearing >= 292.5 && bearing < 337.5) return 'Nord-Ouest';
    return 'Nord';
  }

  // Calculer le temps de trajet estimé
  Map<String, String> calculateTravelTime(double distanceInMeters) {
    // Vitesse moyenne de marche: 5 km/h = 1.39 m/s
    const walkingSpeed = 1.39; // m/s
    // Vitesse moyenne en voiture en ville: 20 km/h = 5.56 m/s
    const drivingSpeed = 5.56; // m/s

    final walkingTimeSeconds = distanceInMeters / walkingSpeed;
    final drivingTimeSeconds = distanceInMeters / drivingSpeed;

    return {
      'walking': _formatTime(walkingTimeSeconds),
      'driving': _formatTime(drivingTimeSeconds),
    };
  }

  String _formatTime(double timeInSeconds) {
    final timeInMinutes = (timeInSeconds / 60).round();

    if (timeInMinutes < 1) {
      return '< 1 min';
    } else if (timeInMinutes < 60) {
      return '$timeInMinutes min';
    } else {
      final hours = timeInMinutes ~/ 60;
      final minutes = timeInMinutes % 60;
      return '${hours}h${minutes > 0 ? ' $minutes min' : ''}';
    }
  }

  // Ouvrir la navigation vers un point
  Future<bool> openNavigation(
    double latitude,
    double longitude,
    String destinationName,
  ) async {
    Uri uri;

    if (Platform.isIOS) {
      uri = Uri.parse('https://maps.apple.com/?daddr=$latitude,$longitude&dirflg=d');
    } else { // Android and other platforms
      uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving');
    }

    try {
      print('[LocationService] Attempting navigation. Platform.isIOS: ${Platform.isIOS}. Target URI: ${uri.toString()}');
      if (await canLaunchUrl(uri)) {
        print('[LocationService] Can launch ${uri.toString()}. Attempting launch...');
        bool success = await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('[LocationService] Launch success for ${uri.toString()}: $success');
        return success;
      } else {
        print('[LocationService] Cannot launch ${uri.toString()}. Trying fallbacks...');
        if (Platform.isAndroid) {
          String query = Uri.encodeComponent(destinationName.isNotEmpty ? destinationName : '$latitude,$longitude');
          final geoUri = Uri.parse('geo:$latitude,$longitude?q=$query');
          print('[LocationService] Trying Android geo intent: ${geoUri.toString()}');
          if (await canLaunchUrl(geoUri)) {
            print('[LocationService] Can launch ${geoUri.toString()}. Attempting launch...');
            bool success = await launchUrl(geoUri, mode: LaunchMode.externalApplication);
            print('[LocationService] Launch success for ${geoUri.toString()}: $success');
            return success;
          } else {
            print('[LocationService] Cannot launch Android geo intent: ${geoUri.toString()}.');
          }
        }
        // As a final fallback for all platforms, try opening Google Maps in a browser
        Uri webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
        print('[LocationService] Trying web fallback: ${webUri.toString()}');
         if (await canLaunchUrl(webUri)) {
            print('[LocationService] Can launch web fallback ${webUri.toString()}. Attempting launch...');
            bool success = await launchUrl(webUri, mode: LaunchMode.platformDefault);
            print('[LocationService] Launch success for web fallback ${webUri.toString()}: $success');
            return success;
        }
        print('[LocationService] Could not launch any map application for navigation. Primary URI: ${uri.toString()}, Web fallback: ${webUri.toString()}');
        return false;
      }
    } catch (e) {
      print('[LocationService] Erreur lors de l\'ouverture de la navigation: $e');
      return false;
    }
  }

  // Ouvrir la navigation à pied
  Future<bool> openWalkingNavigation(
    double latitude,
    double longitude,
    String destinationName,
  ) async {
    try {
      // Prioritize Google Maps for walking directions due to wide support
      final walkingUrl =
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=walking';
      print('[LocationService] Attempting walking navigation. Target URI: $walkingUrl');
      if (await canLaunchUrl(Uri.parse(walkingUrl))) {
        print('[LocationService] Can launch walking URI. Attempting launch...');
        bool success = await launchUrl(
          Uri.parse(walkingUrl),
          mode: LaunchMode.externalApplication,
        );
        print('[LocationService] Launch success for walking URI: $success');
        return success;
      }
      print('[LocationService] Could not launch walking navigation for URI: $walkingUrl');
      return false;
    } catch (e) {
      print('[LocationService] Erreur lors de l\'ouverture de la navigation à pied: $e');
      return false;
    }
  }

  // Appeler un numéro de téléphone
  Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      final phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      print('[LocationService] Attempting phone call. Target URI: ${phoneUri.toString()}');
      if (await canLaunchUrl(phoneUri)) {
        print('[LocationService] Can launch phone URI. Attempting launch...');
        bool success = await launchUrl(phoneUri);
        print('[LocationService] Launch success for phone URI: $success');
        return success;
      }
      print('[LocationService] Could not launch phone dialer for: $phoneNumber');
      return false;
    } catch (e) {
      print('[LocationService] Erreur lors de l\'appel: $e');
      return false;
    }
  }

  // Envoyer un SMS
  Future<bool> sendSMS(String phoneNumber, String message) async {
    try {
      final smsUri = Uri(scheme: 'sms', path: phoneNumber, queryParameters: <String, String>{
        'body': message,
      });
      print('[LocationService] Attempting SMS. Target URI: ${smsUri.toString()}');
      if (await canLaunchUrl(smsUri)) {
         print('[LocationService] Can launch SMS URI. Attempting launch...');
        bool success = await launchUrl(smsUri);
        print('[LocationService] Launch success for SMS URI: $success');
        return success;
      }
      print('[LocationService] Could not launch SMS for: $phoneNumber');
      return false;
    } catch (e) {
      print('[LocationService] Erreur lors de l\'envoi du SMS: $e');
      return false;
    }
  }

  // Calculer l'itinéraire optimal entre plusieurs points
  List<Position> calculateOptimalRoute(List<Position> destinations) {
    // Algorithme simple du plus proche voisin
    if (destinations.isEmpty) return [];

    final List<Position> route = [];
    final List<Position> unvisited = List.from(destinations);

    // Commencer par le point le plus proche de la position actuelle
    Position current = unvisited.removeAt(0); // Assuming destinations are pre-sorted or first is start
    route.add(current);

    while (unvisited.isNotEmpty) {
      Position nearest = unvisited.first;
      double minDistance = calculateDistance(
        current.latitude,
        current.longitude,
        nearest.latitude,
        nearest.longitude,
      );

      for (final destination in unvisited) {
        final distance = calculateDistance(
          current.latitude,
          current.longitude,
          destination.latitude,
          destination.longitude,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearest = destination;
        }
      }

      unvisited.remove(nearest);
      route.add(nearest);
      current = nearest;
    }

    return route;
  }
}
