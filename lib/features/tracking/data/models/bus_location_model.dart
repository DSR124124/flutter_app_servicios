import '../../domain/entities/bus_location.dart';

class BusLocationModel extends BusLocation {
  const BusLocationModel({
    required super.latitude,
    required super.longitude,
    super.heading,
    super.speed,
    required super.timestamp,
  });

  factory BusLocationModel.fromJson(Map<String, dynamic> json) {
    // El backend devuelve timestamp como OffsetDateTime (ISO 8601)
    DateTime timestamp;
    if (json['timestamp'] != null) {
      final timestampStr = json['timestamp'] as String;
      try {
        timestamp = DateTime.parse(timestampStr);
      } catch (e) {
        timestamp = DateTime.now();
      }
    } else {
      timestamp = DateTime.now();
    }
    
    // Soportar tanto campos en inglés como en español del backend
    final lat = (json['latitud'] as num?)?.toDouble() ?? 
                (json['latitude'] as num?)?.toDouble() ?? 0.0;
    final lng = (json['longitud'] as num?)?.toDouble() ?? 
                (json['longitude'] as num?)?.toDouble() ?? 0.0;
    final hdg = (json['rumbo'] as num?)?.toDouble() ?? 
                (json['heading'] as num?)?.toDouble();
    final spd = (json['velocidad'] as num?)?.toDouble() ?? 
                (json['speed'] as num?)?.toDouble();
    
    return BusLocationModel(
      latitude: lat,
      longitude: lng,
      heading: hdg,
      speed: spd,
      timestamp: timestamp,
    );
  }

}

