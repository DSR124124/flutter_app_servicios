import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/bus_location.dart';
import '../../domain/entities/route_point.dart';
import '../../domain/entities/trip_detail.dart';
import '../../domain/entities/stop_eta.dart';
import '../../domain/usecases/get_trip_route_usecase.dart';
import '../../domain/usecases/listen_bus_location_usecase.dart';
import '../../data/datasources/google_distance_matrix_service.dart';

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
  Timer? _etaTimer;
  int? _calculatedETA;
  double? _distanceRemaining;
  List<StopETA> _stopETAs = [];

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
  int? get estimatedArrivalMinutes => _calculatedETA ?? _tripDetail?.estimatedArrivalMinutes;
  double? get distanceRemaining => _distanceRemaining;
  List<StopETA> get stopETAs => _stopETAs;

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

      _startListeningLocation(tripId: tripId, token: token);
      _startETACalculation();
      
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

    bool isFirstLocation = true;

    // Crear nueva suscripción
    _locationSubscription = _listenBusLocationUseCase(
      tripId: tripId,
      token: token,
    ).listen(
      (location) {
        _busPosition = location;
        notifyListeners();
        
        // Calcular ETAs inmediatamente al recibir la primera ubicación
        if (isFirstLocation) {
          isFirstLocation = false;
          _calculateAllETAs();
        }
      },
      onError: (error) {
        _error = error is AppException
            ? error.message
            : 'Error al obtener ubicación';
        notifyListeners();
      },
    );
  }

  /// Inicia el cálculo periódico de ETA para todos los paraderos
  void _startETACalculation() {
    _etaTimer?.cancel();
    
    _etaTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _calculateAllETAs();
    });
  }
  
  Future<void> _calculateAllETAs() async {
    if (_busPosition == null || _tripDetail?.routePoints == null || _tripDetail!.routePoints.isEmpty) {
      return;
    }
    
    final busLocation = LatLng(_busPosition!.latitude, _busPosition!.longitude);
    final routePoints = _tripDetail!.routePoints;
    
    // Calcular ETA al destino final (para mantener compatibilidad)
    final destination = routePoints.last;
    final destinationLocation = LatLng(destination.latitude, destination.longitude);
    
    final finalETA = await GoogleDistanceMatrixService.getETA(
      origin: busLocation,
      destination: destinationLocation,
    );
    
    final finalDistance = await GoogleDistanceMatrixService.getDistance(
      origin: busLocation,
      destination: destinationLocation,
    );
    
    if (finalETA != null && mounted) {
      _calculatedETA = finalETA;
      _distanceRemaining = finalDistance;
    }
    
    // Calcular ETAs para cada paradero
    final stopETAs = <StopETA>[];
    
    for (var i = 0; i < routePoints.length; i++) {
      if (!mounted) return; // Salir si el provider fue disposed
      
      final stop = routePoints[i];
      final stopLocation = LatLng(stop.latitude, stop.longitude);
      
      final eta = await GoogleDistanceMatrixService.getETA(
        origin: busLocation,
        destination: stopLocation,
      );
      
      final distance = await GoogleDistanceMatrixService.getDistance(
        origin: busLocation,
        destination: stopLocation,
      );
      
      stopETAs.add(StopETA(
        stopName: stop.name ?? 'Paradero ${i + 1}',
        latitude: stop.latitude,
        longitude: stop.longitude,
        estimatedMinutes: eta,
        distanceKm: distance,
      ));
      
      // Pequeña pausa para no saturar la API
      await Future.delayed(const Duration(milliseconds: 150));
    }
    
    if (mounted) {
      _stopETAs = stopETAs;
      notifyListeners();
    }
  }
  
  bool get mounted => !_isDisposed;
  bool _isDisposed = false;

  void stopTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _etaTimer?.cancel();
    _etaTimer = null;
    _busPosition = null;
    _calculatedETA = null;
    _distanceRemaining = null;
    _stopETAs = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    stopTracking();
    super.dispose();
  }
}

