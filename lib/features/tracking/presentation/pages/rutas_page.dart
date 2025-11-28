import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../shared/widgets/app_loading_spinner.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../bloc/rutas_provider.dart';
import '../../data/repositories/rutas_repository_impl.dart';

class RutasPage extends StatelessWidget {
  const RutasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.user?.token;
    
    return Scaffold(
        appBar: AppBar(
          title: const Text('Rutas Disponibles'),
          backgroundColor: AppColors.navyDark,
          foregroundColor: AppColors.white,
        ),
      body: ChangeNotifierProvider(
        create: (_) => RutasProvider(
          repository: RutasRepositoryImpl(),
        )..cargarRutas(token: token),
        child: Consumer<RutasProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppGradientSpinner(size: 50),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando rutas disponibles...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.cargarRutas(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (provider.rutas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.route,
                      size: 80,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No hay rutas disponibles',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              );
            }

            final bottomPadding = MediaQuery.of(context).padding.bottom;

            return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                bottomPadding > 0 ? bottomPadding + 16 : 16,
              ),
              itemCount: provider.rutas.length,
              itemBuilder: (context, index) {
                final ruta = provider.rutas[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      context.push('/rutas/${ruta.idRuta}');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 60,
                            decoration: BoxDecoration(
                              color: ruta.colorMapa != null
                                  ? _parseColor(ruta.colorMapa!)
                                  : AppColors.blueLight,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ruta.nombre,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (ruta.descripcion != null &&
                                    ruta.descripcion!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    ruta.descripcion!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${ruta.puntos.length} paraderos',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
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
}
