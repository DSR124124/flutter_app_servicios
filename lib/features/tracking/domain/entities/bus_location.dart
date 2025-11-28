/// Entidad de dominio que representa la ubicación del bus en tiempo real
class BusLocation {
  final double latitude;
  final double longitude;
  final double? heading; // Rumbo en grados (0-360)
  final double? speed; // Velocidad en km/h
  final DateTime timestamp;

  const BusLocation({
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    required this.timestamp,
  });

  factory BusLocation.fromMap(Map<String, dynamic> map) {
    return BusLocation(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      heading: (map['heading'] as num?)?.toDouble(),
      speed: (map['speed'] as num?)?.toDouble(),
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'speed': speed,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

