import '../entities/bus_location.dart';
import '../entities/trip_detail.dart';

/// Repositorio abstracto para tracking de buses
abstract class TrackingRepository {
  /// Escucha actualizaciones de ubicación del bus en tiempo real
  /// Retorna un Stream que emite nuevas ubicaciones
  Stream<BusLocation> listenBusLocation({
    required int tripId,
    String? token,
  });

  /// Obtiene los detalles del viaje incluyendo la ruta completa
  Future<TripDetail> getTripRoute({
    required int tripId,
    String? token,
  });
}

