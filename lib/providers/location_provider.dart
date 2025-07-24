import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Pour LatLng et LatLngBounds
import 'package:flutter_polyline_points/flutter_polyline_points.dart'; // Pour décoder la polyligne

import '../services/location_service.dart';
import '../services/directions_service.dart'; // Ajout du service de directions

class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  final DirectionsService _directionsService = DirectionsService(); // Instance du service de directions

  // État de la localisation utilisateur
  bool _isLoadingLocation = false; // Renommé pour clarté
  String? _error;
  bool _hasPermission = false;

  // Position actuelle
  Position? _currentPosition;
  double? _latitude;
  double? _longitude;

  // Position par défaut (Lomé, Togo)
  static const double _defaultLatitude = 6.1319;
  static const double _defaultLongitude = 1.2228;

  // État de l'itinéraire
  List<LatLng> _polylineCoordinates = [];
  bool _isLoadingRoute = false;
  String? _routeDistance;
  String? _routeDuration;
  LatLngBounds? _routeBounds;
  String? _routeError;

  // Getters pour la localisation utilisateur
  bool get isLoadingLocation => _isLoadingLocation; // Renommé
  String? get error => _error; // Erreur générale du provider (localisation, permission)
  bool get hasPermission => _hasPermission;
  Position? get currentPosition => _currentPosition;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  // Position par défaut si aucune position n'est disponible
  double get effectiveLatitude => _latitude ?? _defaultLatitude;
  double get effectiveLongitude => _longitude ?? _defaultLongitude;

  // Getters pour l'itinéraire
  List<LatLng> get polylineCoordinates => _polylineCoordinates;
  bool get isLoadingRoute => _isLoadingRoute;
  String? get routeDistance => _routeDistance;
  String? get routeDuration => _routeDuration;
  LatLngBounds? get routeBounds => _routeBounds;
  String? get routeError => _routeError;


  // Initialisation
  Future<void> initialize() async {
    _setLoadingLocation(true); // Utilise le setter renommé
    try {
      await _checkPermission();
      if (_hasPermission) {
        await _getCurrentLocation();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoadingLocation(false); // Utilise le setter renommé
    }
  }

  // Vérification des permissions
  Future<void> _checkPermission() async {
    try {
      final permission = await _locationService.checkPermission();
      _hasPermission =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      if (!_hasPermission) {
        final requested = await _locationService.requestPermission();
        _hasPermission =
            requested == LocationPermission.whileInUse ||
            requested == LocationPermission.always;
      }

      notifyListeners();
    } catch (e) {
      _error = 'Erreur de permission: ${e.toString()}';
      _hasPermission = false;
    }
  }

  // Obtenir la position actuelle
  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await _locationService.getCurrentPosition();
      _latitude = _currentPosition!.latitude;
      _longitude = _currentPosition!.longitude;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur de localisation: ${e.toString()}';
      // Utiliser la position par défaut
      _latitude = _defaultLatitude;
      _longitude = _defaultLongitude;
    }
  }

  // Actualiser la position
  Future<void> refreshLocation() async {
    if (!_hasPermission) {
      await _checkPermission();
    }

    if (_hasPermission) {
      _setLoadingLocation(true); // Utilise le setter renommé
      await _getCurrentLocation();
      _setLoadingLocation(false); // Utilise le setter renommé
    }
  }

  // --- Méthodes pour la gestion de l'itinéraire ---

  Future<void> fetchAndSetRoute(LatLng destination) async {
    if (_currentPosition == null) {
      _routeError = "Localisation actuelle de l'utilisateur inconnue.";
      notifyListeners();
      return;
    }

    _isLoadingRoute = true;
    _routeError = null;
    _polylineCoordinates = []; // Effacer l'ancien itinéraire
    notifyListeners();

    try {
      final origin = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      final directionsInfo = await _directionsService.getDirections(origin, destination);

      if (directionsInfo != null) {
        List<PointLatLng> result = PolylinePoints.decodePolyline(directionsInfo['polyline_encoded']);
        if (result.isNotEmpty) {
          _polylineCoordinates = result.map((point) => LatLng(point.latitude, point.longitude)).toList();
        }
        _routeDistance = directionsInfo['distance_text'];
        _routeDuration = directionsInfo['duration_text'];
        _routeBounds = LatLngBounds(
          southwest: directionsInfo['bounds_sw'],
          northeast: directionsInfo['bounds_ne'],
        );
      } else {
        _routeError = "Impossible d'obtenir l'itinéraire.";
      }
    } catch (e) {
      _routeError = "Erreur lors de la récupération de l'itinéraire: ${e.toString()}";
    } finally {
      _isLoadingRoute = false;
      notifyListeners();
    }
  }

  void clearRoute() {
    _polylineCoordinates = [];
    _routeDistance = null;
    _routeDuration = null;
    _routeBounds = null;
    _routeError = null;
    notifyListeners();
  }

  // --- Fin des méthodes pour la gestion de l'itinéraire ---


  // Calculer la distance entre deux points
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Calculer la distance depuis la position actuelle
  double calculateDistanceFromCurrent(double lat, double lon) {
    return calculateDistance(effectiveLatitude, effectiveLongitude, lat, lon);
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

  // Calculer le temps de trajet à pied (estimation)
  String calculateWalkingTime(double distanceInMeters) {
    // Vitesse moyenne de marche: 5 km/h = 1.39 m/s
    const walkingSpeed = 1.39; // m/s
    final timeInSeconds = distanceInMeters / walkingSpeed;
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

  // Calculer le temps de trajet en voiture (estimation)
  String calculateDrivingTime(double distanceInMeters) {
    // Vitesse moyenne en ville: 20 km/h = 5.56 m/s
    const drivingSpeed = 5.56; // m/s
    final timeInSeconds = distanceInMeters / drivingSpeed;
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

  // Vérifier si la localisation est activée
  Future<bool> isLocationEnabled() async {
    try {
      return await _locationService.isLocationEnabled();
    } catch (e) {
      _error = 'Erreur de vérification: ${e.toString()}';
      return false;
    }
  }

  // Demander l'activation de la localisation
  Future<void> requestLocationService() async {
    try {
      await _locationService.requestLocationService();
    } catch (e) {
      _error = 'Erreur d\'activation: ${e.toString()}';
    }
  }

  // Nettoyer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoadingLocation(bool loading) { // Renommé
    _isLoadingLocation = loading;
    notifyListeners();
  }
}
