import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../shared/widgets/app_loading_spinner.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../bloc/ruta_detalle_provider.dart';
import '../utils/map_style_helper.dart';
import '../../data/repositories/rutas_repository_impl.dart';
import '../../domain/entities/ruta.dart';

class RutaDetallePage extends StatefulWidget {
  const RutaDetallePage({
    super.key,
    required this.idRuta,
  });

  final int idRuta;

  @override
  State<RutaDetallePage> createState() => _RutaDetallePageState();
}

class _RutaDetallePageState extends State<RutaDetallePage> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _startIcon;
  BitmapDescriptor? _stopIcon;
  BitmapDescriptor? _endIcon;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isMapInitialized = false;
  bool _hasInitialFit = false;
  Ruta? _lastRuta;
  int? _selectedParaderoIndex;

  @override
  void initState() {
    super.initState();
    _loadMapIcons();
  }

  Future<void> _loadMapIcons() async {
    if (mounted) {
      setState(() {
        _startIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
        _stopIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
        _endIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.user?.token;
    
    return ChangeNotifierProvider(
      create: (_) => RutaDetalleProvider(
        repository: RutasRepositoryImpl(),
      )..cargarRuta(widget.idRuta, token: token),
      child: Consumer<RutaDetalleProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Detalles de Ruta'),
                backgroundColor: AppColors.navyDark,
                foregroundColor: AppColors.white,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppGradientSpinner(size: 50),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando detalles de la ruta...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.error != null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Detalles de Ruta'),
                backgroundColor: AppColors.navyDark,
                foregroundColor: AppColors.white,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Volver'),
                    ),
                  ],
                ),
              ),
            );
          }

          final ruta = provider.ruta;
          if (ruta == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Detalles de Ruta'),
                backgroundColor: AppColors.navyDark,
                foregroundColor: AppColors.white,
              ),
              body: const Center(child: Text('Ruta no encontrada')),
            );
          }

          if (_isMapInitialized && ruta.puntos.isNotEmpty && _lastRuta?.idRuta != ruta.idRuta) {
            _lastRuta = ruta;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _mapController != null) {
                _updateMap(ruta);
                if (ruta.puntos.length > 1 && !_hasInitialFit) {
                  Future.delayed(const Duration(milliseconds: 100), () {
                  _fitBounds(ruta);
                  _hasInitialFit = true;
                  });
                }
              }
            });
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(ruta.nombre),
              backgroundColor: AppColors.navyDark,
              foregroundColor: AppColors.white,
            ),
            body: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildMap(ruta),
                ),
                Expanded(
                  flex: 2,
                  child: _buildInfoSection(ruta, provider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMap(Ruta ruta) {
    if (ruta.puntos.isEmpty) {
      return const Center(child: Text('No hay puntos de ruta disponibles'));
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(ruta.puntos.first.latitude, ruta.puntos.first.longitude),
        zoom: 13.0,
      ),
      minMaxZoomPreference: const MinMaxZoomPreference(10.0, 18.0),
      onMapCreated: (controller) {
        _mapController = controller;
        _isMapInitialized = true;
        // Aplicar estilo personalizado
        controller.setMapStyle(MapStyleHelper.getCustomMapStyle());
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _updateMap(ruta);
            if (ruta.puntos.length > 1) {
              _fitBounds(ruta);
              _hasInitialFit = true;
            }
          }
        });
      },
      markers: _markers,
      polylines: _polylines,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      tiltGesturesEnabled: false,
      compassEnabled: false,
      mapType: MapType.normal,
    );
  }

  void _updateMap(Ruta ruta) {
    if (!_isMapInitialized || _mapController == null || ruta.puntos.isEmpty) return;

    final markers = <Marker>{};
    final color = ruta.colorMapa != null ? _parseColor(ruta.colorMapa!) : AppColors.blueLight;

    final polylines = {
        Polyline(
          polylineId: PolylineId('route_${ruta.idRuta}'),
          points: ruta.puntos.map((p) => LatLng(p.latitude, p.longitude)).toList(),
          color: color,
        width: 6,
        geodesic: true,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
      
      for (var i = 0; i < ruta.puntos.length; i++) {
        final point = ruta.puntos[i];
      final isFirst = i == 0;
      final isLast = i == ruta.puntos.length - 1;
      
        markers.add(
          Marker(
          markerId: MarkerId('stop_${ruta.idRuta}_$i'),
            position: LatLng(point.latitude, point.longitude),
          icon: isFirst
              ? (_startIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen))
              : isLast
                  ? (_endIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed))
                  : (_stopIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)),
            infoWindow: InfoWindow(
              title: point.name ?? 'Paradero ${i + 1}',
            snippet: isFirst ? '🚩 Inicio' : isLast ? '🏁 Fin' : '🚏 Parada $i',
            ),
          ),
        );
    }

    if (mounted) {
    setState(() {
      _markers = markers;
      _polylines = polylines;
    });
    }
  }

  void _fitBounds(Ruta ruta) {
    if (ruta.puntos.length <= 1 || _mapController == null || !mounted) return;

    double minLat = ruta.puntos.first.latitude, maxLat = ruta.puntos.first.latitude;
    double minLng = ruta.puntos.first.longitude, maxLng = ruta.puntos.first.longitude;

    for (final point in ruta.puntos) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final latPadding = (maxLat - minLat) * 0.05;
    final lngPadding = (maxLng - minLng) * 0.05;

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
          12.5,
        ),
      );
    }
  }

  Widget _buildInfoSection(Ruta ruta, RutaDetalleProvider provider) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        bottomPadding > 0 ? bottomPadding + 8 : 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ruta.descripcion != null && ruta.descripcion!.isNotEmpty) ...[
            Text(
              ruta.descripcion!,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Icon(Icons.location_on, size: 20, color: AppColors.blueLight),
              const SizedBox(width: 8),
              Text(
                '${ruta.puntos.length} paraderos',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: ruta.puntos.length,
              itemBuilder: (context, index) {
                final punto = ruta.puntos[index];
                final isFirst = index == 0;
                final isLast = index == ruta.puntos.length - 1;
                
                final isSelected = _selectedParaderoIndex == index;
                
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.blueLight.withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected 
                        ? Border.all(color: AppColors.blueLight, width: 2)
                        : null,
                  ),
                  child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: isFirst 
                          ? Colors.green 
                          : isLast 
                              ? Colors.red 
                              : AppColors.blueLight,
                      radius: 18,
                      child: Icon(
                        isFirst 
                            ? Icons.play_arrow 
                            : isLast 
                                ? Icons.flag 
                                : Icons.location_on,
                        color: AppColors.white,
                        size: 18,
                    ),
                  ),
                  title: Text(
                    punto.name ?? 'Paradero ${index + 1}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isFirst || isLast || isSelected 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                        color: isSelected ? AppColors.blueLight : AppColors.textPrimary,
                  ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: isSelected 
                        ? Icon(Icons.my_location, color: AppColors.blueLight, size: 20)
                        : null,
                  dense: true,
                    visualDensity: VisualDensity.compact,
                    onTap: () async {
                      if (_mapController == null || !_isMapInitialized) {
                        if (mounted) {
                          AppToast.show(
                            context,
                            message: 'Mapa no está listo',
                            type: ToastType.warning,
                            duration: const Duration(seconds: 1),
                          );
                        }
                        return;
                      }
                      
                      setState(() => _selectedParaderoIndex = index);
                      
                      if (mounted) {
                        AppToast.show(
                          context,
                          message: '${isFirst ? '🚩' : isLast ? '🏁' : '📍'} ${punto.name ?? 'Paradero ${index + 1}'}',
                          type: isFirst ? ToastType.success : isLast ? ToastType.error : ToastType.info,
                          duration: const Duration(milliseconds: 1200),
                        );
                      }
                      
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(punto.latitude, punto.longitude),
                          16.0,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (provider.horarios.isNotEmpty) ...[
            const Text(
              'Horarios',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...provider.horarios.take(3).map((horario) {
              String horaInicio = horario.horaInicio;
              String horaFin = horario.horaFin;
              
              if (horaInicio.contains('T')) {
                horaInicio = horaInicio.split('T')[1].split('.')[0].substring(0, 5);
              }
              if (horaFin.contains('T')) {
                horaFin = horaFin.split('T')[1].split('.')[0].substring(0, 5);
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      '$horaInicio - $horaFin',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.push('/buses-activos/${ruta.idRuta}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueLight,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Buses Activos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.blueLight;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
