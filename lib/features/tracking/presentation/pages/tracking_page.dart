import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../shared/widgets/app_loading_spinner.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../bloc/tracking_provider.dart';
import '../utils/map_icon_helper.dart';
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

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initialPosition, zoom: 14.0),
      minMaxZoomPreference: const MinMaxZoomPreference(10.0, 18.0),
      onMapCreated: (controller) {
        _mapController = controller;
        _isMapInitialized = true;
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _updateMap(provider);
        });
      },
      markers: _markers,
      polylines: _polylines,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      tiltGesturesEnabled: false,
      trafficEnabled: true,
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
          rotation: busPosition.heading ?? 0.0,
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(
            title: '🚌 Bus en movimiento',
            snippet: busPosition.speed != null ? '${busPosition.speed!.toStringAsFixed(1)} km/h' : null,
          ),
          zIndex: 1000,
        ),
      );

      if (!_hasInitialFit) {
        if (routePoints.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 300), () {
            _fitBounds([
              ...routePoints.map((p) => LatLng(p.latitude, p.longitude)),
              busLatLng,
            ]);
          });
        } else {
          _mapController?.animateCamera(CameraUpdate.newLatLngZoom(busLatLng, 15.0));
        }
        _hasInitialFit = true;
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

  void _fitBounds(List<LatLng> points) {
    if (points.isEmpty || _mapController == null || !mounted) return;

    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final latPadding = (maxLat - minLat) * 0.1;
    final lngPadding = (maxLng - minLng) * 0.1;

    try {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat - latPadding, minLng - lngPadding),
            northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
          ),
          80.0,
        ),
      );
    } catch (e) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2),
          14.0,
        ),
      );
    }
  }

  Widget _buildInfoPanel(TrackingProvider provider) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
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

    return FloatingActionButton(
      onPressed: () {
        final pos = provider.busPosition!;
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(pos.latitude, pos.longitude),
            16.0,
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.directions_bus, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Centrando en el bus...'),
                  ],
                ),
                duration: Duration(milliseconds: 800),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.blueLight,
              ),
            );
        }
      },
      backgroundColor: AppColors.blueLight,
      child: const Icon(Icons.my_location, color: AppColors.white, size: 28),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
