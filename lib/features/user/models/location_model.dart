import 'dart:math';

class Location {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;

  const Location({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
  });

  /// Calculate distance to another location using Haversine formula
  /// Returns distance in kilometers
  double distanceTo(Location other) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double lat1Rad = latitude * (pi / 180);
    final double lat2Rad = other.latitude * (pi / 180);
    final double deltaLatRad = (other.latitude - latitude) * (pi / 180);
    final double deltaLonRad = (other.longitude - longitude) * (pi / 180);

    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLonRad / 2) * sin(deltaLonRad / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Check if this location is within a certain radius of another location
  bool isWithinRadius(Location other, double radiusKm) {
    return distanceTo(other) <= radiusKm;
  }

  factory Location.fromGeoPoint(dynamic geoPoint) {
    return Location(
      latitude: geoPoint.latitude,
      longitude: geoPoint.longitude,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      accuracy: map['accuracy']?.toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Location copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    DateTime? timestamp,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Location &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() {
    return 'Location(lat: ${latitude.toStringAsFixed(6)}, lng: ${longitude.toStringAsFixed(6)})';
  }
}