import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_loading_spinner.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../../../auth/presentation/pages/perfil_page.dart';
import '../../data/repositories/servicios_repository_impl.dart';
import '../../domain/usecases/actualizar_servicio_usecase.dart';
import '../../domain/usecases/crear_servicio_usecase.dart';
import '../../domain/usecases/eliminar_servicio_usecase.dart';
import '../../domain/usecases/get_servicio_por_id_usecase.dart';
import '../../domain/usecases/get_servicios_usecase.dart';
import '../bloc/servicios_provider.dart';
import '../widgets/servicios_list.dart';

class ServiciosPage extends StatelessWidget {
  const ServiciosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiciosProvider(
        getServiciosUseCase: GetServiciosUseCase(
          ServiciosRepositoryImpl(
            authRepository: context.read<AuthProvider>().repository,
          ),
        ),
        getServicioPorIdUseCase: GetServicioPorIdUseCase(
          ServiciosRepositoryImpl(
            authRepository: context.read<AuthProvider>().repository,
          ),
        ),
        crearServicioUseCase: CrearServicioUseCase(
          ServiciosRepositoryImpl(
            authRepository: context.read<AuthProvider>().repository,
          ),
        ),
        actualizarServicioUseCase: ActualizarServicioUseCase(
          ServiciosRepositoryImpl(
            authRepository: context.read<AuthProvider>().repository,
          ),
        ),
        eliminarServicioUseCase: EliminarServicioUseCase(
          ServiciosRepositoryImpl(
            authRepository: context.read<AuthProvider>().repository,
          ),
        ),
      ),
      child: const _ServiciosView(),
    );
  }
}

class _ServiciosView extends StatefulWidget {
  const _ServiciosView();

  @override
  State<_ServiciosView> createState() => _ServiciosViewState();
}

class _ServiciosViewState extends State<_ServiciosView> {
  int _currentPageIndex = 0; // 0 = Servicios, 1 = Perfil

  Future<void> _handleLogout() async {
    // Mostrar spinner de carga
    AppGradientSpinner.showOverlay(
      context,
      message: 'Cerrando sesión...',
    );

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();

      if (!mounted) return;

      // Ocultar spinner
      AppGradientSpinner.hideOverlay(context);
      
      // Mostrar toast de éxito
      AppToast.show(
        context,
        message: 'Sesión cerrada exitosamente',
        type: ToastType.success,
      );
    } catch (e) {
      // Ocultar spinner en caso de error
      if (mounted) {
        AppGradientSpinner.hideOverlay(context);
        AppToast.show(
          context,
          message: 'Error al cerrar sesión',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final serviciosProvider = context.watch<ServiciosProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPageIndex == 0 
            ? AppStrings.serviciosTitle 
            : AppStrings.menuMiPerfil),
      ),
      drawer: _buildDrawer(context, user),
      body: _currentPageIndex == 0
          ? _buildServiciosBody(serviciosProvider)
          : const PerfilPage(),
      floatingActionButton: _currentPageIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Implementar diálogo para crear servicio
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildDrawer(BuildContext context, user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    (user?.username?.isNotEmpty == true 
                        ? user!.username![0] 
                        : 'U').toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.username ?? 'Usuario',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user?.rol != null)
                  Text(
                    user!.rol,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text(AppStrings.menuServicios),
            selected: _currentPageIndex == 0,
            onTap: () {
              setState(() {
                _currentPageIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text(AppStrings.menuMiPerfil),
            selected: _currentPageIndex == 1,
            onTap: () {
              setState(() {
                _currentPageIndex = 1;
              });
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              AppStrings.menuCerrarSesion,
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              Navigator.pop(context);
              _handleLogout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiciosBody(ServiciosProvider serviciosProvider) {
    return serviciosProvider.isInitialLoading
          ? const Center(
              child: AppLoadingSpinner(
                message: 'Cargando servicios...',
              ),
            )
          : serviciosProvider.error != null && serviciosProvider.servicios.isEmpty
              ? Center(
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
                        serviciosProvider.error!,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: serviciosProvider.loadServicios,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : serviciosProvider.hasServicios
                  ? ServiciosList(servicios: serviciosProvider.servicios)
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 80,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            AppStrings.serviciosEmpty,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Los servicios que tengas asignados aparecerán aquí',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
  }
}

