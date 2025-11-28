/// Punto de la ruta (paradero o punto de referencia)
class RoutePoint {
  final double latitude;
  final double longitude;
  final String? name; // Nombre del paradero
  final int? order; // Orden en la ruta

  const RoutePoint({
    required this.latitude,
    required this.longitude,
    this.name,
    this.order,
  });

  factory RoutePoint.fromMap(Map<String, dynamic> map) {
    // Soporta tanto campos en inglés como en español (del backend)
    return RoutePoint(
      latitude: (map['latitud'] as num?)?.toDouble() ?? 
                (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitud'] as num?)?.toDouble() ?? 
                 (map['longitude'] as num?)?.toDouble() ?? 0.0,
      name: map['nombreParadero'] as String? ?? map['name'] as String?,
      order: (map['orden'] as num?)?.toInt() ?? 
             (map['order'] as num?)?.toInt(),
    );
  }
  
  // Constructor alternativo para compatibilidad con diferentes formatos
  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint.fromMap(json);
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'order': order,
    };
  }
}

