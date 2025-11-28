import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/services/app_info_service.dart';
import '../../../../shared/widgets/app_loading_spinner.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../app_update/presentation/bloc/app_update_provider.dart';
import '../../../app_update/presentation/widgets/app_update_dialog.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../../../auth/presentation/pages/perfil_page.dart';

class ServiciosPage extends StatelessWidget {
  const ServiciosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ServiciosView();
  }
}

class _ServiciosView extends StatefulWidget {
  const _ServiciosView();

  @override
  State<_ServiciosView> createState() => _ServiciosViewState();
}

class _ServiciosViewState extends State<_ServiciosView> {
  int _currentPageIndex = 0; // 0 = Servicios, 1 = Perfil
  final AppUpdateProvider _updateProvider = AppUpdateProvider();
  final AppInfoService _appInfoService = AppInfoService();
  bool _hasCheckedForUpdates = false;
  String _installedVersion = '';

  @override
  void initState() {
    super.initState();
    // Verificar actualizaciones después de que se construya el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
      _loadInstalledVersion();
    });
  }

  Future<void> _loadInstalledVersion() async {
    final version = await _appInfoService.getCurrentVersion();
    if (!mounted) return;
    setState(() {
      _installedVersion = version;
    });
  }

  /// Verifica si hay actualizaciones disponibles
  Future<void> _checkForUpdates() async {
    if (_hasCheckedForUpdates) return;
    _hasCheckedForUpdates = true;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user == null) return;

    await _updateProvider.checkForUpdates(
      idUsuario: user.idUsuario,
      token: user.token,
    );

    if (_updateProvider.hasUpdate && mounted) {
      AppUpdateDialog.show(
        context,
        updateInfo: _updateProvider.availableUpdate!,
        onDismiss: _updateProvider.dismissUpdate,
      );
    }
  }

  Future<void> _handleLogout() async {
    if (!mounted) return;
    
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
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textoHeader,
        title: Text(_currentPageIndex == 0 
            ? AppStrings.serviciosTitle 
            : AppStrings.menuMiPerfil),
      ),
      drawer: _buildDrawer(context, user),
      body: Stack(
        children: [
          // Contenido principal
          _currentPageIndex == 0
              ? _buildServiciosBody()
              : const PerfilPage(),
          // Versión de la app solo visible en Servicios
          if (_currentPageIndex == 0) _buildVersionBadge(),
        ],
      ),
    );
  }

  /// Widget para mostrar la versión instalada de la app
  Widget _buildVersionBadge() {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: AppColors.border.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Versión ${_installedVersion.isEmpty ? '...' : _installedVersion}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, user) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.white,
                  child: Text(
                    (user?.username?.isNotEmpty == true 
                        ? user!.username![0] 
                        : 'U').toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.username ?? 'Usuario',
                  style: const TextStyle(
                    color: AppColors.textoHeader,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user?.rol != null)
                  Text(
                    user!.rol,
                    style: TextStyle(
                      color: AppColors.textoHeader.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.person_outline,
              color: _currentPageIndex == 1 
                  ? AppColors.primary 
                  : AppColors.textSecondary,
            ),
            title: Text(
              AppStrings.menuMiPerfil,
              style: TextStyle(
                color: _currentPageIndex == 1 
                    ? AppColors.primary 
                    : AppColors.textPrimary,
                fontWeight: _currentPageIndex == 1 
                    ? FontWeight.w600 
                    : FontWeight.normal,
              ),
            ),
            selected: _currentPageIndex == 1,
            selectedTileColor: AppColors.primary.withOpacity(0.1),
            onTap: () {
              setState(() {
                _currentPageIndex = 1;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.work_outline,
              color: _currentPageIndex == 0 
                  ? AppColors.primary 
                  : AppColors.textSecondary,
            ),
            title: Text(
              AppStrings.menuServicios,
              style: TextStyle(
                color: _currentPageIndex == 0 
                    ? AppColors.primary 
                    : AppColors.textPrimary,
                fontWeight: _currentPageIndex == 0 
                    ? FontWeight.w600 
                    : FontWeight.normal,
              ),
            ),
            selected: _currentPageIndex == 0,
            selectedTileColor: AppColors.primary.withOpacity(0.1),
            onTap: () {
              setState(() {
                _currentPageIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.description_outlined,
              color: AppColors.textSecondary,
            ),
            title: const Text(
              AppStrings.menuTerminos,
              style: TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              context.push('/terminos');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.privacy_tip_outlined,
              color: AppColors.textSecondary,
            ),
            title: const Text(
              AppStrings.menuPrivacidad,
              style: TextStyle(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              context.push('/privacidad');
            },
          ),
          const Divider(
            color: AppColors.border,
            height: 1,
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: AppColors.error,
            ),
            title: const Text(
              AppStrings.menuCerrarSesion,
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () async {
              Navigator.pop(context);
              // Pequeño delay para que el drawer se cierre antes de mostrar el spinner
              await Future.delayed(const Duration(milliseconds: 100));
              if (mounted) {
                _handleLogout();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiciosBody() {
    return Stack(
      children: [
        // Contenido principal centrado con padding para la versión
        Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: Center(
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
          ),
        ),
        // Botones de acción (Chatbot y Transporte)
        Positioned(
          top: 16,
          left: 16,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón del Chatbot
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        context.push('/chatbot');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.smart_toy,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Chatbot',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Botón de Transporte
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: AppColors.blueLight,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        context.push('/rutas');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.directions_bus,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Transporte',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

