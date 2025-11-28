import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  BitmapDescriptor? _stopIcon;
  BitmapDescriptor? _endIcon;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  String? _lastErrorMessage;
  bool _isMapInitialized = false;
  bool _hasInitialFit = false;
  BusLocation? _lastBusPosition;

  @override
  void initState() {
    super.initState();
    _loadMapIcons();
  }

  Future<void> _loadMapIcons() async {
    final busIcon = await MapIconHelper.createBusIcon();
    if (mounted) {
      setState(() {
        _busIcon = busIcon;
        _startIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
        _stopIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
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

    // Configuración 3D tipo navegación: tilt de 45° y zoom más cercano
    final initialBearing = provider.busPosition?.heading ?? 0.0;
    
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 19.0, // Zoom muy cercano para ver el bus de cerca
        tilt: 45.0, // Inclinación 3D tipo navegación
        bearing: initialBearing, // Dirección basada en el heading del bus
      ),
      minMaxZoomPreference: const MinMaxZoomPreference(10.0, 21.0),
      onMapCreated: (controller) {
        _mapController = controller;
        _isMapInitialized = true;
        // Aplicar estilo personalizado
        controller.setMapStyle(MapStyleHelper.getCustomMapStyle());
        // Centrar inmediatamente en el bus si está disponible
        if (provider.busPosition != null) {
          final busPos = provider.busPosition!;
          final busLatLng = LatLng(busPos.latitude, busPos.longitude);
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted && _mapController != null) {
              _mapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: busLatLng,
                    zoom: 19.0, // Zoom muy cercano
                    tilt: 45.0,
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
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      tiltGesturesEnabled: true, // Habilitado para permitir ajuste manual
      rotateGesturesEnabled: true, // Habilitado para rotar el mapa
      compassEnabled: false,
      trafficEnabled: true,
      mapType: MapType.normal,
    );
  }

  void _updateMap(TrackingProvider provider) {
    if (!_isMapInitialized || _mapController == null) return;

    final routePoints = provider.routePolyline;
    final busPosition = provider.busPosition;
    
    if (busPosition == _lastBusPosition && _markers.isNotEmpty) return;

    final markers = <Marker>{};
    final polylines = <Polyline>{};

    if (routePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: routePoints.map((p) => LatLng(p.latitude, p.longitude)).toList(),
          color: AppColors.blueLight,
          width: 6,
          geodesic: true,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );

      for (var i = 0; i < routePoints.length; i++) {
        final point = routePoints[i];
        final isFirst = i == 0;
        final isLast = i == routePoints.length - 1;
        
        markers.add(
          Marker(
            markerId: MarkerId('stop_$i'),
            position: LatLng(point.latitude, point.longitude),
            icon: isFirst 
                ? (_startIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen))
                : isLast 
                    ? (_endIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed))
                    : (_stopIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)),
            infoWindow: InfoWindow(
              title: point.name ?? 'Paradero ${i + 1}',
              snippet: isFirst ? '🚩 Inicio' : isLast ? '🏁 Fin' : '🚏 Parada',
            ),
          ),
        );
      }
    }

    if (busPosition != null && _busIcon != null) {
      final busLatLng = LatLng(busPosition.latitude, busPosition.longitude);
      
      markers.add(
        Marker(
          markerId: const MarkerId('bus'),
          position: busLatLng,
          icon: _busIcon!,
          rotation: busPosition.heading ?? 0.0, // Rotación según orientación de recorrido
          anchor: const Offset(0.5, 0.5), // Centro del ícono
          flat: false, // Permitir rotación 3D
          infoWindow: InfoWindow(
            title: '🚌 Bus en movimiento',
            snippet: busPosition.speed != null ? '${busPosition.speed!.toStringAsFixed(1)} km/h' : null,
          ),
          zIndex: 1000,
        ),
      );

      if (!_hasInitialFit) {
        // Centrar inmediatamente en el bus al iniciar con zoom muy cercano
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: busLatLng,
              zoom: 19.0, // Zoom muy cercano para ver el bus de cerca
              tilt: 45.0,
              bearing: busPosition.heading ?? 0.0, // Rotación según orientación
            ),
          ),
        );
        _hasInitialFit = true;
      } else {
        // Actualizar cámara en tiempo real con efecto 3D de navegación
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: busLatLng,
              zoom: 19.0, // Mantener zoom cercano
              tilt: 45.0,
              bearing: busPosition.heading ?? 0.0, // Rotación según orientación del recorrido
            ),
          ),
        );
      }
    }

    if (mounted) {
    setState(() {
      _markers = markers;
      _polylines = polylines;
      _lastBusPosition = busPosition;
    });
    }
  }

  /// Ajusta la cámara en modo 3D tipo navegación con tilt y bearing
  void _fitBounds3D(List<LatLng> points, double bearing) {
    if (points.isEmpty || _mapController == null || !mounted) return;

    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    
    try {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: center,
            zoom: 19.0, // Zoom muy cercano para ver el bus de cerca
            tilt: 45.0, // Inclinación 3D
            bearing: bearing, // Dirección del bus según orientación
          ),
        ),
      );
    } catch (e) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: center,
            zoom: 17.0,
            tilt: 45.0,
            bearing: bearing,
          ),
        ),
      );
    }
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
        // Re-centrar en modo 3D navegación
        _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(pos.latitude, pos.longitude),
                zoom: 19.0, // Zoom muy cercano
                tilt: 45.0,
                bearing: pos.heading ?? 0.0, // Rotación según orientación
              ),
            ),
          );
          if (mounted) {
            AppToast.show(
              context,
              message: '🚌 Centrando en el bus...',
              type: ToastType.info,
              duration: const Duration(milliseconds: 800),
        );
          }
      },
      backgroundColor: AppColors.blueLight,
        child: const Icon(Icons.my_location, color: AppColors.white, size: 28),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
