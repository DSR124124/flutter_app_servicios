import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../shared/widgets/app_loading_spinner.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../bloc/ruta_detalle_provider.dart';
import '../../data/repositories/rutas_repository_impl.dart';
import '../../data/models/ruta_completa_model.dart';

class BusesActivosPage extends StatelessWidget {
  const BusesActivosPage({
    super.key,
    required this.idRuta,
  });

  final int idRuta;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.user?.token;
    
    return ChangeNotifierProvider(
      create: (_) => RutaDetalleProvider(
        repository: RutasRepositoryImpl(),
      )..cargarRuta(idRuta, token: token),
      child: Consumer<RutaDetalleProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Buses Activos'),
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
                      'Cargando buses activos...',
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
                title: const Text('Buses Activos'),
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
                title: const Text('Buses Activos'),
                backgroundColor: AppColors.navyDark,
                foregroundColor: AppColors.white,
              ),
              body: const Center(child: Text('Ruta no encontrada')),
            );
          }

          final busesActivos = provider.viajesActivos
              .where((viaje) => viaje.idRuta == idRuta)
              .toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Buses - ${ruta.nombre}'),
              backgroundColor: AppColors.navyDark,
              foregroundColor: AppColors.white,
            ),
            body: busesActivos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_bus_outlined,
                          size: 80,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No hay buses activos',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No hay buses en ruta para esta línea',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : _buildBusesList(context, busesActivos),
          );
        },
      ),
    );
  }

  Widget _buildBusesList(BuildContext context, List<ViajeActivoModel> buses) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        bottomPadding > 0 ? bottomPadding + 16 : 16,
      ),
      itemCount: buses.length,
      itemBuilder: (context, index) {
        final viaje = buses[index];
        final isActivo = viaje.estado.toLowerCase() == 'en_curso';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActivo 
                  ? AppColors.blueLight 
                  : AppColors.textSecondary.withOpacity(0.3),
              width: isActivo ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActivo 
                    ? AppColors.blueLight.withOpacity(0.1) 
                    : AppColors.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.directions_bus,
                color: isActivo 
                    ? AppColors.blueLight 
                    : AppColors.textSecondary.withOpacity(0.5),
                size: 28,
              ),
            ),
            title: Text(
              viaje.busPlate,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isActivo 
                    ? AppColors.textPrimary 
                    : AppColors.textSecondary.withOpacity(0.5),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (viaje.busModel != null && viaje.busModel!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    viaje.busModel!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isActivo 
                          ? AppColors.textSecondary 
                          : AppColors.textSecondary.withOpacity(0.5),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 14,
                      color: isActivo 
                          ? AppColors.textSecondary 
                          : AppColors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      viaje.driverName,
                      style: TextStyle(
                        fontSize: 12,
                        color: isActivo 
                            ? AppColors.textSecondary 
                            : AppColors.textSecondary.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActivo 
                        ? AppColors.blueLight.withOpacity(0.1) 
                        : AppColors.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActivo ? 'En ruta' : viaje.estado,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isActivo 
                          ? AppColors.blueLight 
                          : AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
            trailing: isActivo
                ? IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 20),
                    color: AppColors.blueLight,
                    onPressed: () {
                      context.push('/tracking/${viaje.idViaje}');
                    },
                  )
                : Icon(
                    Icons.block,
                    color: AppColors.textSecondary.withOpacity(0.3),
                    size: 24,
                  ),
            enabled: isActivo,
            onTap: isActivo
                ? () {
                    context.push('/tracking/${viaje.idViaje}');
                  }
                : null,
          ),
        );
      },
    );
  }
}
