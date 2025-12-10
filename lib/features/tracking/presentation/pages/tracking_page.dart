import 'dart:math' show cos, sin;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../shared/widgets/app_loading_spinner.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../bloc/tracking_provider.dart';
import '../utils/map_icon_helper.dart';
import '../utils/map_style_helper.dart';
import '../widgets/trip_info_panel.dart';
import '../../data/repositories/tracking_repository_impl.dart';
import '../../data/datasources/google_directions_service.dart';
import '../../domain/entities/bus_location.dart';
import '../../domain/usecases/get_trip_route_usecase.dart';
import '../../domain/usecases/listen_bus_location_usecase.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({
    super.key,
    required this.tripId,
    this.token,
  });

  final int tripId;
  final String? token;

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _busIcon;
  BitmapDescriptor? _startIcon;
  BitmapDescriptor? _endIcon;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  String? _lastErrorMessage;
  bool _isMapInitialized = false;
  bool _hasInitialFit = false;
  BusLocation? _lastBusPosition;
  List<LatLng>? _optimizedRoute;
  bool _isLoadingRoute = false;
  bool _hasLocationPermission = false;

  @override
  void initState() {
    super.initState();
    _loadMapIcons();
    _ensureLocationPermission();
  }

  Future<void> _loadMapIcons() async {
    final busIcon = await MapIconHelper.createBusIcon();
    if (mounted) {
      setState(() {
        _busIcon = busIcon;
        _startIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
        _endIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final token = widget.token ?? authProvider.user?.token;
    
    return ChangeNotifierProvider(
      create: (_) => TrackingProvider(
        listenBusLocationUseCase: ListenBusLocationUseCase(
          TrackingRepositoryImpl(),
        ),
        getTripRouteUseCase: GetTripRouteUseCase(
          TrackingRepositoryImpl(),
        ),
      )..initializeTracking(
          tripId: widget.tripId,
          token: token,
        ),
      child: Builder(
        builder: (context) {
          final provider = context.watch<TrackingProvider>();
          
          if (provider.error != null && provider.error != _lastErrorMessage) {
            _lastErrorMessage = provider.error;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              AppToast.show(context, message: provider.error!, type: ToastType.error);
            });
          }

          if (_isMapInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateMap(provider);
            });
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Seguimiento de Viaje'),
              backgroundColor: AppColors.navyDark,
              foregroundColor: AppColors.white,
            ),
            body: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: _buildMap(provider),
                ),
                _buildInfoPanel(provider),
              ],
            ),
            floatingActionButton: _buildRecenteringFAB(provider),
          );
        },
      ),
    );
  }

  Widget _buildMap(TrackingProvider provider) {
    if (provider.isInitialLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppGradientSpinner(size: 50),
            const SizedBox(height: 16),
            Text(
              'Conectando con el vehículo...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final initialPosition = provider.busPosition != null
        ? LatLng(provider.busPosition!.latitude, provider.busPosition!.longitude)
        : const LatLng(-12.0464, -77.0428);

    final initialBearing = provider.busPosition?.heading ?? 0.0;
    
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 18.5,
        tilt: 60.0,
        bearing: initialBearing,
      ),
      minMaxZoomPreference: const MinMaxZoomPreference(10.0, 20.0),
      onMapCreated: (controller) {
        _mapController = controller;
        _isMapInitialized = true;
        controller.setMapStyle(MapStyleHelper.getCustomMapStyle());
        
        if (provider.busPosition != null) {
          final busPos = provider.busPosition!;
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted && _mapController != null) {
              _mapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(busPos.latitude, busPos.longitude),
                    zoom: 18.5,
                    tilt: 60.0,
                    bearing: busPos.heading ?? 0.0,
                  ),
                ),
              );
            }
          });
        }
        
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _updateMap(provider);
        });
      },
      markers: _markers,
      polylines: _polylines,
      myLocationButtonEnabled: _hasLocationPermission,
      myLocationEnabled: _hasLocationPermission,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      tiltGesturesEnabled: true, // Habilitado para permitir ajuste manual
      rotateGesturesEnabled: true, // Habilitado para rotar el mapa
      compassEnabled: false,
      trafficEnabled: true,
      mapType: MapType.normal,
    );
  }

  /// Solicita permisos de ubicación y actualiza el estado para mostrar el punto azul
  Future<void> _ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'No se otorgaron permisos de ubicación.',
          type: ToastType.warning,
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _hasLocationPermission = true;
      });
    }
  }

  void _updateMap(TrackingProvider provider) {
    if (!_isMapInitialized || _mapController == null) return;

    final routePoints = provider.routePolyline;
    final busPosition = provider.busPosition;
    
    // Solo evitar actualización si no hay cambios significativos
    if (busPosition == _lastBusPosition && 
        _markers.isNotEmpty && 
        _optimizedRoute != null) {
      return;
    }

    final markers = <Marker>{};
    final polylines = <Polyline>{};

    // Cargar ruta optimizada usando Directions API
    if (routePoints.isNotEmpty && _optimizedRoute == null && !_isLoadingRoute) {
      _isLoadingRoute = true;
      final waypoints = routePoints.map((p) => LatLng(p.latitude, p.longitude)).toList();
      
      GoogleDirectionsService.getOptimizedRoute(waypoints).then((optimizedRoute) {
        if (mounted) {
          setState(() {
            _optimizedRoute = optimizedRoute;
            _isLoadingRoute = false;
          });
          // Volver a actualizar el mapa ahora que tenemos la ruta
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) _updateMap(provider);
          });
        }
      }).catchError((_) {
        if (mounted) {
          setState(() {
            _optimizedRoute = waypoints; // Fallback a ruta manual
            _isLoadingRoute = false;
          });
          // Volver a actualizar el mapa con el fallback
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) _updateMap(provider);
          });
        }
      });
      return; // Salir temprano para no dibujar mientras carga
    }

    // Dibujar la ruta optimizada única sin nodos
    if (_optimizedRoute != null && _optimizedRoute!.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: _optimizedRoute!,
          color: AppColors.blueLight,
          width: 10, // Grosor aumentado para mejor visibilidad
          geodesic: true,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );
    }

    // Agregar marcadores para TODOS los paraderos
    for (var i = 0; i < routePoints.length; i++) {
      final point = routePoints[i];
      final isFirst = i == 0;
      final isLast = i == routePoints.length - 1;
      
      BitmapDescriptor icon;
      if (isFirst) {
        icon = _startIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      } else if (isLast) {
        icon = _endIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      } else {
        // Paraderos intermedios con marcador azul
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      }
      
      markers.add(
        Marker(
          markerId: MarkerId('paradero_$i'),
          position: LatLng(point.latitude, point.longitude),
          icon: icon,
          infoWindow: InfoWindow(
            title: point.name ?? 'Paradero ${i + 1}',
            snippet: isFirst ? '🚩 Inicio' : isLast ? '🏁 Fin' : '🚏 Parada',
          ),
        ),
      );
    }

    if (busPosition != null && _busIcon != null) {
      final busLatLng = LatLng(busPosition.latitude, busPosition.longitude);
      final heading = busPosition.heading ?? 0.0;
      final speed = busPosition.speed ?? 0.0;
      final isMoving = speed > 1;
      
      // Círculo de posición del bus (más visible)
      if (isMoving) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('bus_circle'),
            points: _generateCirclePoints(busLatLng, 20), // 20 metros de radio
            color: AppColors.blueLight.withOpacity(0.3),
            width: 2,
            geodesic: true,
          ),
        );
      }
      
      markers.add(
        Marker(
          markerId: const MarkerId('bus'),
          position: busLatLng,
          icon: _busIcon!,
          rotation: heading,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          infoWindow: InfoWindow(
            title: isMoving ? '🚌 Bus en movimiento' : '🚌 Bus detenido',
            snippet: '${speed.toStringAsFixed(0)} km/h',
          ),
          zIndex: 1000,
        ),
      );

      // Animar cámara solo si el bus se movió significativamente o es la primera vez
      final shouldUpdate = _lastBusPosition == null || 
          _shouldUpdateCamera(busLatLng, LatLng(_lastBusPosition!.latitude, _lastBusPosition!.longitude));
      
      if (shouldUpdate) {
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: busLatLng,
              zoom: 18.5,
              tilt: 60.0,
              bearing: heading,
            ),
          ),
        );
      }
      
      if (!_hasInitialFit) _hasInitialFit = true;
    }

    if (mounted) {
      setState(() {
        _markers = markers;
        _polylines = polylines;
        _lastBusPosition = busPosition;
      });
    }
  }

  bool _shouldUpdateCamera(LatLng newPosition, LatLng? oldPosition) {
    if (oldPosition == null) return true;
    
    // Calcular distancia entre posiciones (aproximada)
    final latDiff = (newPosition.latitude - oldPosition.latitude).abs();
    final lngDiff = (newPosition.longitude - oldPosition.longitude).abs();
    
    // Actualizar si se movió más de ~5 metros (0.00005 grados ≈ 5 metros)
    return latDiff > 0.00005 || lngDiff > 0.00005;
  }

  List<LatLng> _generateCirclePoints(LatLng center, double radiusInMeters) {
    final points = <LatLng>[];
    const earthRadius = 6371000.0; // Radio de la Tierra en metros
    final lat = center.latitude * (3.141592653589793 / 180);
    final lng = center.longitude * (3.141592653589793 / 180);
    
    for (int i = 0; i <= 32; i++) {
      final angle = (i * 360 / 32) * (3.141592653589793 / 180);
      final dx = radiusInMeters * cos(angle);
      final dy = radiusInMeters * sin(angle);
      
      final newLat = lat + (dy / earthRadius);
      final newLng = lng + (dx / (earthRadius * cos(lat)));
      
      points.add(LatLng(
        newLat * (180 / 3.141592653589793),
        newLng * (180 / 3.141592653589793),
      ));
    }
    
    return points;
  }

  Widget _buildInfoPanel(TrackingProvider provider) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomPadding > 0 ? bottomPadding : 0,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: TripInfoPanel(
          driverName: provider.driverName,
          driverPhoto: provider.driverPhoto,
          busPlate: provider.busPlate,
          busModel: provider.busModel,
          tripStatus: provider.tripStatus,
          estimatedArrivalMinutes: provider.estimatedArrivalMinutes,
          distanceRemaining: provider.distanceRemaining,
          stopETAs: provider.stopETAs,
        ),
      ),
    );
  }

  Widget _buildRecenteringFAB(TrackingProvider provider) {
    if (provider.busPosition == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom > 0 
            ? MediaQuery.of(context).padding.bottom + 8 
            : 16,
      ),
      child: FloatingActionButton(
        onPressed: () {
          final pos = provider.busPosition!;
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(pos.latitude, pos.longitude),
                zoom: 18.5,
                tilt: 60.0,
                bearing: pos.heading ?? 0.0,
              ),
            ),
          );
        },
        backgroundColor: AppColors.blueLight,
        child: const Icon(Icons.my_location, color: AppColors.white, size: 26),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
