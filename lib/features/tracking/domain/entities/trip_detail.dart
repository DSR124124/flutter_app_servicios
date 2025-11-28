import 'route_point.dart';

/// Detalles del viaje incluyendo ruta, información del bus y conductor
class TripDetail {
  final int tripId;
  final String busPlate; // Placa del bus
  final String? busModel; // Modelo del bus
  final String driverName; // Nombre del conductor
  final String? driverPhoto; // URL de foto del conductor
  final List<RoutePoint> routePoints; // Puntos de la ruta (polyline)
  final String? status; // Estado del viaje (ej: "En camino", "A 5 minutos")
  final int? estimatedArrivalMinutes; // Tiempo estimado de llegada en minutos

  const TripDetail({
    required this.tripId,
    required this.busPlate,
    this.busModel,
    required this.driverName,
    this.driverPhoto,
    required this.routePoints,
    this.status,
    this.estimatedArrivalMinutes,
  });

  factory TripDetail.fromMap(Map<String, dynamic> map) {
    final routePointsList = map['routePoints'] as List<dynamic>? ?? [];
    return TripDetail(
      tripId: (map['tripId'] as num?)?.toInt() ?? 0,
      busPlate: map['busPlate'] as String? ?? '',
      busModel: map['busModel'] as String?,
      driverName: map['driverName'] as String? ?? '',
      driverPhoto: map['driverPhoto'] as String?,
      routePoints: routePointsList
          .map((point) => RoutePoint.fromMap(point as Map<String, dynamic>))
          .toList(),
      status: map['status'] as String?,
      estimatedArrivalMinutes: (map['estimatedArrivalMinutes'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'busPlate': busPlate,
      'busModel': busModel,
      'driverName': driverName,
      'driverPhoto': driverPhoto,
      'routePoints': routePoints.map((point) => point.toMap()).toList(),
      'status': status,
      'estimatedArrivalMinutes': estimatedArrivalMinutes,
    };
  }
}

