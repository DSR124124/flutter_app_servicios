import '../../domain/entities/trip_detail.dart';
import '../../domain/entities/route_point.dart';

class TripDetailModel extends TripDetail {
  const TripDetailModel({
    required super.tripId,
    required super.busPlate,
    super.busModel,
    required super.driverName,
    super.driverPhoto,
    required super.routePoints,
    super.status,
    super.estimatedArrivalMinutes,
  });

  factory TripDetailModel.fromJson(Map<String, dynamic> json) {
    final routePointsList = json['routePoints'] as List<dynamic>? ?? [];
    return TripDetailModel(
      tripId: (json['tripId'] as num?)?.toInt() ?? 0,
      busPlate: json['busPlate'] as String? ?? '',
      busModel: json['busModel'] as String?,
      driverName: json['driverName'] as String? ?? '',
      driverPhoto: json['driverPhoto'] as String?,
      routePoints: routePointsList
          .map((point) => RoutePoint.fromMap(point as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String?,
      estimatedArrivalMinutes: (json['estimatedArrivalMinutes'] as num?)?.toInt(),
    );
  }

}

