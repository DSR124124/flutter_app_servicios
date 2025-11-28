import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/bus_location.dart';
import '../../domain/entities/route_point.dart';
import '../../domain/entities/trip_detail.dart';
import '../../domain/usecases/get_trip_route_usecase.dart';
import '../../domain/usecases/listen_bus_location_usecase.dart';

/// Provider para manejar el estado del tracking del bus
class TrackingProvider extends ChangeNotifier {
  TrackingProvider({
    required ListenBusLocationUseCase listenBusLocationUseCase,
    required GetTripRouteUseCase getTripRouteUseCase,
  })  : _listenBusLocationUseCase = listenBusLocationUseCase,
        _getTripRouteUseCase = getTripRouteUseCase;

  final ListenBusLocationUseCase _listenBusLocationUseCase;
  final GetTripRouteUseCase _getTripRouteUseCase;

  // Estado
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _error;
  TripDetail? _tripDetail;
  BusLocation? _busPosition;
  StreamSubscription<BusLocation>? _locationSubscription;

  bool get isLoading => _isLoading;
  bool get isInitialLoading => _isInitialLoading;
  String? get error => _error;
  BusLocation? get busPosition => _busPosition;
  List<RoutePoint> get routePolyline => _tripDetail?.routePoints ?? [];
  String get driverName => _tripDetail?.driverName ?? '';
  String? get driverPhoto => _tripDetail?.driverPhoto;
  String get busPlate => _tripDetail?.busPlate ?? '';
  String? get busModel => _tripDetail?.busModel;
  String get tripStatus => _tripDetail?.status ?? 'En camino';
  int? get estimatedArrivalMinutes => _tripDetail?.estimatedArrivalMinutes;

  /// Inicializa el tracking para un viaje
  Future<void> initializeTracking({
    required int tripId,
    String? token,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _isInitialLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Obtener detalles del viaje y ruta
      _tripDetail = await _getTripRouteUseCase(
        tripId: tripId,
        token: token,
      );

      // 2. Iniciar escucha de ubicación en tiempo real
      _startListeningLocation(
        tripId: tripId,
        token: token,
      );

      _error = null;
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = AppException.unknown().message;
    } finally {
      _isLoading = false;
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  /// Inicia la escucha de ubicación en tiempo real
  void _startListeningLocation({
    required int tripId,
    String? token,
  }) {
    // Cancelar suscripción anterior si existe
    _locationSubscription?.cancel();

    // Crear nueva suscripción
    _locationSubscription = _listenBusLocationUseCase(
      tripId: tripId,
      token: token,
    ).listen(
      (location) {
        _busPosition = location;
        notifyListeners();
      },
      onError: (error) {
        _error = error is AppException
            ? error.message
            : 'Error al obtener ubicación';
        notifyListeners();
      },
    );
  }

  /// Detiene el tracking y limpia recursos
  void stopTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _busPosition = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}

