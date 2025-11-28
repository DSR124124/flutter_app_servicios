import '../entities/bus_location.dart';
import '../repositories/tracking_repository.dart';

/// UseCase para escuchar actualizaciones de ubicación del bus en tiempo real
class ListenBusLocationUseCase {
  ListenBusLocationUseCase(this._repository);

  final TrackingRepository _repository;

  /// Retorna un Stream que emite nuevas ubicaciones del bus
  /// 
  /// Parámetros:
  /// - tripId: ID del viaje a seguir
  /// - token: Token de autenticación (opcional)
  Stream<BusLocation> call({
    required int tripId,
    String? token,
  }) {
    return _repository.listenBusLocation(
      tripId: tripId,
      token: token,
    );
  }
}

