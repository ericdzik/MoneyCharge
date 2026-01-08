import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:locacharge/features/user/models/location_model.dart';

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  whileInUse,
  unknown
}

class GeolocationService {
  static final GeolocationService _instance = GeolocationService._internal();
  factory GeolocationService() => _instance;
  GeolocationService._internal();

  Location? _lastKnownLocation;
  StreamSubscription<Position>? _positionStreamSubscription;
  final StreamController<Location> _locationController = StreamController<Location>.broadcast();

  /// Stream of location updates
  Stream<Location> get locationStream => _locationController.stream;

  /// Check if location services are enabled on the device
  Future<bool> get isLocationServiceEnabled async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check if location tracking is currently enabled
  bool get isLocationEnabled => _lastKnownLocation != null;

  /// Get the last known location without requesting a new one
  Location? get lastKnownLocation => _lastKnownLocation;

  /// Request location permission from the user
  Future<LocationPermissionStatus> requestPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.denied;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationPermissionStatus.denied;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionStatus.deniedForever;
      }

      // Convert Geolocator permission to our enum
      switch (permission) {
        case LocationPermission.always:
        case LocationPermission.whileInUse:
          return LocationPermissionStatus.granted;
        case LocationPermission.denied:
          return LocationPermissionStatus.denied;
        case LocationPermission.deniedForever:
          return LocationPermissionStatus.deniedForever;
        default:
          return LocationPermissionStatus.unknown;
      }
    } catch (e) {
      print('Error requesting location permission: $e');
      return LocationPermissionStatus.unknown;
    }
  }

  /// Get the current location of the user
  Future<Location?> getCurrentLocation() async {
    try {
      // Check permission first
      final permissionStatus = await requestPermission();
      if (permissionStatus != LocationPermissionStatus.granted) {
        print('Location permission not granted: $permissionStatus');
        return _lastKnownLocation; // Return cached location if available
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final location = Location(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
      );

      _lastKnownLocation = location;
      _locationController.add(location);

      return location;
    } catch (e) {
      print('Error getting current location: $e');
      return _lastKnownLocation; // Return cached location if available
    }
  }

  /// Start continuous location tracking
  Future<void> startLocationTracking() async {
    try {
      final permissionStatus = await requestPermission();
      if (permissionStatus != LocationPermissionStatus.granted) {
        print('Cannot start location tracking: permission not granted');
        return;
      }

      // Stop existing stream if any
      await stopLocationTracking();

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100, // Update every 100 meters
      );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          final location = Location(
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
            timestamp: DateTime.now(),
          );

          _lastKnownLocation = location;
          _locationController.add(location);
        },
        onError: (error) {
          print('Location stream error: $error');
        },
      );
    } catch (e) {
      print('Error starting location tracking: $e');
    }
  }

  /// Stop continuous location tracking
  Future<void> stopLocationTracking() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  /// Calculate distance between two locations using Haversine formula
  double calculateDistance(Location from, Location to) {
    return from.distanceTo(to);
  }

  /// Check if a location is within a certain radius of another location
  bool isWithinRadius(Location center, Location target, double radiusKm) {
    return center.isWithinRadius(target, radiusKm);
  }

  /// Get a fallback location (could be city center or last known location)
  Location? getFallbackLocation() {
    // Return last known location if available
    if (_lastKnownLocation != null) {
      return _lastKnownLocation;
    }

    // Could return a default city center location
    // For now, return null to indicate no location available
    return null;
  }

  /// Dispose of resources
  void dispose() {
    stopLocationTracking();
    _locationController.close();
  }
}