import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

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
  });

  final String driverName;
  final String? driverPhoto;
  final String busPlate;
  final String? busModel;
  final String tripStatus;
  final int? estimatedArrivalMinutes;

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
                const Icon(Icons.location_on, color: AppColors.tealDark, size: 20),
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
        ],
      ),
    );
  }

  String _formatETA(int minutes) {
    if (minutes < 60) return 'Llegada estimada: $minutes min';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return 'Llegada estimada: $hours ${hours == 1 ? 'hora' : 'horas'}';
    }
    return 'Llegada estimada: $hours h $remainingMinutes min';
  }
}

