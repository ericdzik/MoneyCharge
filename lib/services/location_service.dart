import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb for web check
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService {
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

    if (kIsWeb) {
      // For web, always use the Google Maps web URL to open in a new tab.
      // Using 'dir/' API to try and get directions directly.
      uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving');
      print('[LocationService] Web platform detected. Attempting to launch URI: ${uri.toString()}');
      try {
        if (await canLaunchUrl(uri)) {
          print('[LocationService] Can launch web URI. Attempting launch...');
          // For web, platformDefault is often better to open in a new tab.
          bool success = await launchUrl(uri, mode: LaunchMode.platformDefault);
          print('[LocationService] Launch success for web URI: $success');
          return success;
        } else {
          print('[LocationService] Cannot launch web URI: ${uri.toString()}');
          // Try a simpler search query as a further web fallback
          Uri webSearchUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
          print('[LocationService] Trying simpler web search fallback: ${webSearchUri.toString()}');
          if (await canLaunchUrl(webSearchUri)){
            print('[LocationService] Can launch simpler web search. Attempting launch...');
            bool success = await launchUrl(webSearchUri, mode: LaunchMode.platformDefault);
            print('[LocationService] Launch success for simpler web search: $success');
            return success;
          }
          print('[LocationService] Cannot launch simpler web search URI: ${webSearchUri.toString()}');
          return false;
        }
      } catch (e) {
        print('[LocationService] Erreur lors de l\'ouverture de la navigation web: $e');
        return false;
      }
    } else if (Platform.isIOS) {
      uri = Uri.parse('https://maps.apple.com/?daddr=$latitude,$longitude&dirflg=d');
      print('[LocationService] iOS platform detected. Attempting to launch Apple Maps URI: ${uri.toString()}');
    } else { // Android and other non-web native platforms
      uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving');
      print('[LocationService] Android/Other native platform detected. Attempting to launch Google Maps Dir URI: ${uri.toString()}');
    }

    // Native platforms attempt sequence
    try {
      if (await canLaunchUrl(uri)) {
        print('[LocationService] Can launch native URI ${uri.toString()}. Attempting launch...');
        bool success = await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('[LocationService] Launch success for native URI ${uri.toString()}: $success');
        return success;
      } else {
        print('[LocationService] Cannot launch native URI ${uri.toString()}. Trying fallbacks for native...');
        if (Platform.isAndroid) {
          String query = Uri.encodeComponent(destinationName.isNotEmpty ? destinationName : '$latitude,$longitude');
          final geoUri = Uri.parse('geo:$latitude,$longitude?q=$query');
          print('[LocationService] Trying Android geo intent: ${geoUri.toString()}');
          if (await canLaunchUrl(geoUri)) {
            print('[LocationService] Can launch Android geo intent. Attempting launch...');
            bool success = await launchUrl(geoUri, mode: LaunchMode.externalApplication);
            print('[LocationService] Launch success for Android geo intent: $success');
            return success;
          } else {
            print('[LocationService] Cannot launch Android geo intent: ${geoUri.toString()}.');
          }
        }
        // Fallback for native if specific app URIs fail - try opening web version
        Uri webFallbackForNative = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
        print('[LocationService] Trying web fallback for native: ${webFallbackForNative.toString()}');
        if(await canLaunchUrl(webFallbackForNative)){
            bool success = await launchUrl(webFallbackForNative, mode: LaunchMode.platformDefault);
            print('[LocationService] Launch success for web fallback for native: $success');
            return success;
        }
        print('[LocationService] All native app launch attempts and web fallback failed for URI: ${uri.toString()}');
        return false;
      }
    } catch (e) {
      print('[LocationService] Erreur lors de l\'ouverture de la navigation native: $e');
      return false;
    }
  }

  Future<bool> openWalkingNavigation(
    double latitude,
    double longitude,
    String destinationName,
  ) async {
    Uri uri;
    if (kIsWeb) {
        uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=walking');
        print('[LocationService] Web - Attempting walking navigation. Target URI: ${uri.toString()}');
    } else if (Platform.isIOS) {
        // Apple Maps walking: 'https://maps.apple.com/?daddr=$latitude,$longitude&dirflg=w'
        uri = Uri.parse('https://maps.apple.com/?daddr=$latitude,$longitude&dirflg=w');
        print('[LocationService] iOS - Attempting walking navigation. Target URI: ${uri.toString()}');
    } else { // Android and other native
        uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=walking');
        print('[LocationService] Android/Other - Attempting walking navigation. Target URI: ${uri.toString()}');
    }

    try {
      if (await canLaunchUrl(uri)) {
        print('[LocationService] Can launch walking URI. Attempting launch...');
        bool success = await launchUrl(uri, mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication);
        print('[LocationService] Launch success for walking URI: $success');
        return success;
      }
      print('[LocationService] Could not launch walking navigation for URI: ${uri.toString()}');
      return false;
    } catch (e) {
      print('[LocationService] Erreur lors de l\'ouverture de la navigation à pied: $e');
      return false;
    }
  }

  Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      final phoneUri = Uri(scheme: 'tel', path: phoneNumber.replaceAll(RegExp(r'\s+'), '')); // Remove spaces for safety
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

  Future<bool> sendSMS(String phoneNumber, String message) async {
    try {
      final smsUri = Uri(scheme: 'sms', path: phoneNumber.replaceAll(RegExp(r'\s+'), ''), queryParameters: <String, String>{
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
