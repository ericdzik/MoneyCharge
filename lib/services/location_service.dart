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
    try {
      // Essayer d'abord Google Maps
      final googleMapsUrl =
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';

      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        return await launchUrl(
          Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      }

      // Fallback vers Apple Maps (iOS) ou autres applications
      final fallbackUrl =
          'https://maps.apple.com/?daddr=$latitude,$longitude&dirflg=d';
      return await launchUrl(
        Uri.parse(fallbackUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('Erreur lors de l\'ouverture de la navigation: $e');
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
      final walkingUrl =
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=walking';

      if (await canLaunchUrl(Uri.parse(walkingUrl))) {
        return await launchUrl(
          Uri.parse(walkingUrl),
          mode: LaunchMode.externalApplication,
        );
      }
      return false;
    } catch (e) {
      print('Erreur lors de l\'ouverture de la navigation à pied: $e');
      return false;
    }
  }

  // Appeler un numéro de téléphone
  Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      final phoneUrl = 'tel:$phoneNumber';

      if (await canLaunchUrl(Uri.parse(phoneUrl))) {
        return await launchUrl(
          Uri.parse(phoneUrl),
          mode: LaunchMode.externalApplication,
        );
      }
      return false;
    } catch (e) {
      print('Erreur lors de l\'appel: $e');
      return false;
    }
  }

  // Envoyer un SMS
  Future<bool> sendSMS(String phoneNumber, String message) async {
    try {
      final smsUrl = 'sms:$phoneNumber?body=${Uri.encodeComponent(message)}';

      if (await canLaunchUrl(Uri.parse(smsUrl))) {
        return await launchUrl(
          Uri.parse(smsUrl),
          mode: LaunchMode.externalApplication,
        );
      }
      return false;
    } catch (e) {
      print('Erreur lors de l\'envoi du SMS: $e');
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
    Position current = unvisited.removeAt(0);
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
