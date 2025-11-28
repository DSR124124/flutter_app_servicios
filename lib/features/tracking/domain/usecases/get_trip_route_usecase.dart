import '../entities/trip_detail.dart';
import '../repositories/tracking_repository.dart';

/// UseCase para obtener los detalles del viaje y la ruta completa
class GetTripRouteUseCase {
  GetTripRouteUseCase(this._repository);

  final TrackingRepository _repository;

  /// Obtiene los detalles del viaje incluyendo:
  /// - Información del bus y conductor
  /// - Lista de puntos de la ruta (para dibujar polyline)
  /// - Estado del viaje y ETA
  /// 
  /// Parámetros:
  /// - tripId: ID del viaje
  /// - token: Token de autenticación (opcional)
  Future<TripDetail> call({
    required int tripId,
    String? token,
  }) {
    return _repository.getTripRoute(
      tripId: tripId,
      token: token,
    );
  }
}

