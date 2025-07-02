import 'dart:io' show Platform;
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService {
  // Temporarily empty to ensure import works
  // Methods will be added back if this compiles.

  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
  }

  Future<bool> isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<void> requestLocationService() async {
    await Geolocator.openLocationSettings();
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

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

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  Future<Position?> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition();
  }

  bool isWithinRadius(
    double centerLat,
    double centerLon,
    double targetLat,
    double targetLon,
    double radiusInMeters,
  ) {
    final distance = calculateDistance(centerLat, centerLon, targetLat, targetLon);
    return distance <= radiusInMeters;
  }

  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

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

  Map<String, String> calculateTravelTime(double distanceInMeters) {
    const walkingSpeed = 1.39;
    const drivingSpeed = 5.56;
    final walkingTimeSeconds = distanceInMeters / walkingSpeed;
    final drivingTimeSeconds = distanceInMeters / drivingSpeed;
    return {
      'walking': _formatTime(walkingTimeSeconds),
      'driving': _formatTime(drivingTimeSeconds),
    };
  }

  String _formatTime(double timeInSeconds) {
    final timeInMinutes = (timeInSeconds / 60).round();
    if (timeInMinutes < 1) return '< 1 min';
    if (timeInMinutes < 60) return '$timeInMinutes min';
    final hours = timeInMinutes ~/ 60;
    final minutes = timeInMinutes % 60;
    return '${hours}h${minutes > 0 ? ' $minutes min' : ''}';
  }

  Future<bool> openNavigation(
    double latitude,
    double longitude,
    String destinationName,
  ) async {
    Uri uri;
    if (Platform.isIOS) {
      uri = Uri.parse('https://maps.apple.com/?daddr=$latitude,$longitude&dirflg=d');
    } else {
      uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving');
    }
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (Platform.isAndroid) {
          String query = Uri.encodeComponent(destinationName.isNotEmpty ? destinationName : '$latitude,$longitude');
          final geoUri = Uri.parse('geo:$latitude,$longitude?q=$query');
          if (await canLaunchUrl(geoUri)) {
            return await launchUrl(geoUri, mode: LaunchMode.externalApplication);
          }
        }
        Uri webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
         if (await canLaunchUrl(webUri)) {
            return await launchUrl(webUri, mode: LaunchMode.platformDefault);
        }
        print('Could not launch any map application for navigation for URI: $uri or web fallback.');
        return false;
      }
    } catch (e) {
      print('Erreur lors de l\'ouverture de la navigation: $e');
      return false;
    }
  }

  Future<bool> openWalkingNavigation(
    double latitude,
    double longitude,
    String destinationName,
  ) async {
    try {
      final walkingUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=walking';
      if (await canLaunchUrl(Uri.parse(walkingUrl))) {
        return await launchUrl(Uri.parse(walkingUrl), mode: LaunchMode.externalApplication);
      }
      print('Could not launch walking navigation for URI: $walkingUrl');
      return false;
    } catch (e) {
      print('Erreur lors de l\'ouverture de la navigation à pied: $e');
      return false;
    }
  }

  Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      final phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        return await launchUrl(phoneUri);
      }
      print('Could not launch phone dialer for: $phoneNumber');
      return false;
    } catch (e) {
      print('Erreur lors de l\'appel: $e');
      return false;
    }
  }

  Future<bool> sendSMS(String phoneNumber, String message) async {
    try {
      final smsUri = Uri(scheme: 'sms', path: phoneNumber, queryParameters: <String, String>{'body': message});
      if (await canLaunchUrl(smsUri)) {
        return await launchUrl(smsUri);
      }
      print('Could not launch SMS for: $phoneNumber');
      return false;
    } catch (e) {
      print('Erreur lors de l\'envoi du SMS: $e');
      return false;
    }
  }

  List<Position> calculateOptimalRoute(List<Position> destinations) {
    if (destinations.isEmpty) return [];
    final List<Position> route = [];
    final List<Position> unvisited = List.from(destinations);
    Position current = unvisited.removeAt(0);
    route.add(current);
    while (unvisited.isNotEmpty) {
      Position nearest = unvisited.first;
      double minDistance = calculateDistance(current.latitude, current.longitude, nearest.latitude, nearest.longitude);
      for (final destination in unvisited) {
        final distance = calculateDistance(current.latitude, current.longitude, destination.latitude, destination.longitude);
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
