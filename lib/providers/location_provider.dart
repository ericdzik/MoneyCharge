import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();

  // État de la localisation
  bool _isLoading = false;
  String? _error;
  bool _hasPermission = false;

  // Position actuelle
  Position? _currentPosition;
  double? _latitude;
  double? _longitude;

  // Position par défaut (Lomé, Togo)
  static const double _defaultLatitude = 6.1319;
  static const double _defaultLongitude = 1.2228;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasPermission => _hasPermission;
  Position? get currentPosition => _currentPosition;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  // Position par défaut si aucune position n'est disponible
  double get effectiveLatitude => _latitude ?? _defaultLatitude;
  double get effectiveLongitude => _longitude ?? _defaultLongitude;

  // Initialisation
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _checkPermission();
      if (_hasPermission) {
        await _getCurrentLocation();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
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
      _setLoading(true);
      await _getCurrentLocation();
      _setLoading(false);
    }
  }

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

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
