import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../domain/entities/servicio.dart';

class ServiciosList extends StatelessWidget {
  const ServiciosList({
    super.key,
    required this.servicios,
  });

  final List<Servicio> servicios;

  @override
  Widget build(BuildContext context) {
    if (servicios.isEmpty) {
      return const Center(
        child: Text('No hay servicios disponibles'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: servicios.length,
      itemBuilder: (context, index) {
        final servicio = servicios[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getEstadoColor(servicio.estado),
              child: Icon(
                _getEstadoIcon(servicio.estado),
                color: Colors.white,
              ),
            ),
            title: Text(
              servicio.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(servicio.descripcion),
                const SizedBox(height: 4),
                Chip(
                  label: Text(
                    servicio.estado,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: _getEstadoColor(servicio.estado).withOpacity(0.2),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.error, size: 20),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                // TODO: Implementar acciones de editar/eliminar
              },
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'ACTIVO':
        return AppColors.success;
      case 'INACTIVO':
        return AppColors.textSecondary;
      case 'PENDIENTE':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado.toUpperCase()) {
      case 'ACTIVO':
        return Icons.check_circle;
      case 'INACTIVO':
        return Icons.cancel;
      case 'PENDIENTE':
        return Icons.pending;
      default:
        return Icons.help_outline;
    }
  }
}

