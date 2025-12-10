import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../shared/widgets/app_loading_spinner.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../bloc/rutas_provider.dart';
import '../widgets/seleccionar_ruta_paradero_dialog.dart';
import '../../data/repositories/rutas_repository_impl.dart';
import '../../data/repositories/registro_ruta_repository_impl.dart';
import '../../domain/usecases/registrar_ruta_paradero_usecase.dart';
import '../../domain/entities/registro_ruta.dart';

class RutasPage extends StatefulWidget {
  const RutasPage({super.key});

  @override
  State<RutasPage> createState() => _RutasPageState();
}

class _RutasPageState extends State<RutasPage> {
  bool _dialogoMostrado = false;
  RegistroRuta? _ultimoRegistro;
  bool _verificandoRegistro = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarRegistroPrevio();
    });
  }

  Future<void> _verificarRegistroPrevio() async {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.user?.token;

    if (token == null) {
      setState(() {
        _verificandoRegistro = false;
      });
      return;
    }

    try {
      final useCase = ObtenerUltimoRegistroUseCase(RegistroRutaRepositoryImpl());
      final registro = await useCase(token: token);

      if (mounted) {
        setState(() {
          _ultimoRegistro = registro;
          _verificandoRegistro = false;
        });

        if (registro == null && !_dialogoMostrado) {
          _mostrarDialogoSeleccion();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _verificandoRegistro = false;
        });
        if (!_dialogoMostrado) {
          _mostrarDialogoSeleccion();
        }
      }
    }
  }

  void _mostrarDialogoSeleccion() {
    setState(() => _dialogoMostrado = true);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SeleccionarRutaParaderoDialog(
        registroPrevio: _ultimoRegistro,
        onRegistroCompletado: () => _verificarRegistroPrevio(),
      ),
    ).then((_) {
      setState(() => _dialogoMostrado = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.user?.token;

    if (_verificandoRegistro) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rutas Disponibles'),
          backgroundColor: AppColors.navyDark,
          foregroundColor: AppColors.white,
        ),
        body: const Center(
          child: AppGradientSpinner(size: 50),
        ),
      );
    }
    
    return Scaffold(
        appBar: AppBar(
          title: const Text('Rutas Disponibles'),
          backgroundColor: AppColors.navyDark,
          foregroundColor: AppColors.white,
          actions: [
            if (_ultimoRegistro != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Text(
                    'Ruta: ${_ultimoRegistro!.nombreRuta}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.edit_location),
              tooltip: _ultimoRegistro != null 
                  ? 'Actualizar ruta y paradero' 
                  : 'Seleccionar ruta y paradero',
              onPressed: _mostrarDialogoSeleccion,
            ),
          ],
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
