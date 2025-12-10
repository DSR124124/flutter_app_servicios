import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../domain/entities/stop_eta.dart';

/// Panel flotante que muestra información del viaje
class TripInfoPanel extends StatelessWidget {
  const TripInfoPanel({
    super.key,
    required this.driverName,
    this.driverPhoto,
    required this.busPlate,
    this.busModel,
    required this.tripStatus,
    this.estimatedArrivalMinutes,
    this.distanceRemaining,
    this.stopETAs = const [],
  });

  final String driverName;
  final String? driverPhoto;
  final String busPlate;
  final String? busModel;
  final String tripStatus;
  final int? estimatedArrivalMinutes;
  final double? distanceRemaining;
  final List<StopETA> stopETAs;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return DraggableScrollableSheet(
          initialChildSize: 0.35,
          minChildSize: 0.2,
          maxChildSize: 0.7,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle para arrastrar
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grayMedium,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Contenido scrolleable
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        bottomPadding > 0 ? bottomPadding + 8 : 16,
                      ),
                      children: [
                        _buildDriverSection(),
                        const SizedBox(height: 16),
                        _buildBusSection(),
                        const SizedBox(height: 16),
                        _buildStatusSection(),
                        if (stopETAs.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildStopsSection(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDriverSection() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.blueLight,
          backgroundImage: driverPhoto != null ? NetworkImage(driverPhoto!) : null,
          child: driverPhoto == null
              ? Text(
                  driverName.isNotEmpty ? driverName[0].toUpperCase() : 'C',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Conductor',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grayMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                driverName.isNotEmpty ? driverName : 'No disponible',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoContent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grayLighter,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_bus, color: AppColors.blueLight, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vehículo',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grayMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  busPlate,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textoContent,
                  ),
                ),
                if (busModel != null && busModel!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    busModel!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grayMedium,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blueLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.blueLight.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: AppColors.blueLight, size: 20),
              const SizedBox(width: 8),
              Text(
                tripStatus,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueLight,
                ),
              ),
            ],
          ),
          if (estimatedArrivalMinutes != null && estimatedArrivalMinutes! > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.schedule, color: AppColors.tealDark, size: 20),
                const SizedBox(width: 8),
                Text(
                  _formatETA(estimatedArrivalMinutes!),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.tealDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (distanceRemaining != null && distanceRemaining! > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.blueLight, size: 20),
                const SizedBox(width: 8),
                Text(
                  _formatDistance(distanceRemaining!),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.blueLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStopsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grayLighter,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: const Row(
            children: [
              Icon(Icons.timeline, color: AppColors.blueLight, size: 22),
              SizedBox(width: 12),
              Text(
                'Paraderos de la ruta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoContent,
                ),
              ),
            ],
          ),
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: stopETAs.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final stop = stopETAs[index];
                final isFirst = index == 0;
                final isLast = index == stopETAs.length - 1;
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Icono del paradero
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isFirst 
                              ? Colors.green.withOpacity(0.1) 
                              : isLast 
                                  ? Colors.red.withOpacity(0.1)
                                  : AppColors.blueLight.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFirst 
                              ? Icons.flag 
                              : isLast 
                                  ? Icons.location_on 
                                  : Icons.circle,
                          color: isFirst 
                              ? Colors.green 
                              : isLast 
                                  ? Colors.red 
                                  : AppColors.blueLight,
                          size: isFirst || isLast ? 20 : 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Nombre del paradero
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stop.stopName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textoContent,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (stop.distanceKm != null && stop.distanceKm! > 0) ...[
                              const SizedBox(height: 2),
                              Text(
                                stop.formattedDistance,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grayMedium,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // ETA
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getETAColor(stop.estimatedMinutes).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          stop.formattedETA,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getETAColor(stop.estimatedMinutes),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getETAColor(int? minutes) {
    if (minutes == null) return AppColors.grayMedium;
    if (minutes < 5) return Colors.green;
    if (minutes < 15) return Colors.orange;
    return AppColors.blueLight;
  }

  String _formatETA(int minutes) {
    if (minutes < 60) return 'Llegada en $minutes min';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return 'Llegada en $hours ${hours == 1 ? 'hora' : 'horas'}';
    }
    return 'Llegada en $hours h $remainingMinutes min';
  }

  String _formatDistance(double kilometers) {
    if (kilometers < 1) {
      return 'Distancia: ${(kilometers * 1000).round()} m';
    }
    return 'Distancia: ${kilometers.toStringAsFixed(1)} km';
  }
}

