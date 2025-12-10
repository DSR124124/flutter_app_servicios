import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../shared/widgets/app_loading_spinner.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../bloc/rutas_provider.dart';
import '../../domain/entities/ruta.dart';
import '../../domain/entities/route_point.dart';
import '../../data/repositories/rutas_repository_impl.dart';
import '../../data/repositories/registro_ruta_repository_impl.dart';
import '../../domain/usecases/registrar_ruta_paradero_usecase.dart';
import '../../domain/entities/registro_ruta.dart';

class SeleccionarRutaParaderoDialog extends StatefulWidget {
  const SeleccionarRutaParaderoDialog({
    super.key,
    this.registroPrevio,
    this.onRegistroCompletado,
  });

  final RegistroRuta? registroPrevio;
  final VoidCallback? onRegistroCompletado;

  @override
  State<SeleccionarRutaParaderoDialog> createState() =>
      _SeleccionarRutaParaderoDialogState();
}

class _SeleccionarRutaParaderoDialogState
    extends State<SeleccionarRutaParaderoDialog> {
  Ruta? _rutaSeleccionada;
  RoutePoint? _paraderoSeleccionado;
  bool _isRegistrando = false;
  bool _cargandoRuta = false;

  @override
  void initState() {
    super.initState();
    if (widget.registroPrevio != null) {
      _cargarRutaPrevia();
    }
  }

  Future<void> _cargarRutaPrevia() async {
    if (widget.registroPrevio == null) return;

    setState(() => _cargandoRuta = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.user?.token;
      final repository = RutasRepositoryImpl();
      final ruta = await repository.obtenerRutaPorId(
        widget.registroPrevio!.idRuta,
        token: token,
      );

      if (mounted) {
        setState(() {
          _rutaSeleccionada = ruta;
          if (ruta.puntos.isNotEmpty) {
            _paraderoSeleccionado = ruta.puntos.firstWhere(
              (p) => p.idPunto == widget.registroPrevio!.idParadero,
              orElse: () => ruta.puntos.first,
            );
          }
          _cargandoRuta = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargandoRuta = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.user?.token;
    final tieneRegistroPrevio = widget.registroPrevio != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_bus,
                  color: AppColors.blueLight,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tieneRegistroPrevio
                        ? 'Actualizar Ruta y Paradero'
                        : 'Selecciona tu Ruta y Paradero',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tieneRegistroPrevio
                  ? 'Tu selección actual: ${widget.registroPrevio!.nombreRuta} - ${widget.registroPrevio!.nombreParadero}. Puedes actualizarla aquí.'
                  : 'Para continuar, selecciona la ruta que vas a tomar y el paradero donde subirás.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            if (_cargandoRuta)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: AppGradientSpinner(size: 30),
                ),
              )
            else ...[
              _buildRutaSelector(context, token),
              const SizedBox(height: 16),
              if (_rutaSeleccionada != null) ...[
                _buildParaderoSelector(),
                const SizedBox(height: 24),
              ],
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _puedeRegistrar() && !_isRegistrando
                      ? () => _registrarRutaParadero(context, token)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueLight,
                    foregroundColor: AppColors.white,
                  ),
                  child: _isRegistrando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                      : const Text('Continuar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRutaSelector(BuildContext context, String? token) {
    return ChangeNotifierProvider(
      create: (_) => RutasProvider(
        repository: RutasRepositoryImpl(),
      )..cargarRutas(token: token),
      child: Consumer<RutasProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const SizedBox(
              height: 50,
              child: Center(child: AppGradientSpinner(size: 30)),
            );
          }

          if (provider.error != null) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.error!,
                      style: TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.rutas.isEmpty) {
            return const Text(
              'No hay rutas disponibles',
              style: TextStyle(color: AppColors.textSecondary),
            );
          }

          Ruta? rutaParaMostrar = _rutaSeleccionada;
          if (_rutaSeleccionada != null) {
            try {
              final rutaEnLista = provider.rutas.firstWhere(
                (r) => r.idRuta == _rutaSeleccionada!.idRuta,
              );
              rutaParaMostrar = (rutaEnLista.puntos.isEmpty && _rutaSeleccionada!.puntos.isNotEmpty)
                  ? _rutaSeleccionada
                  : rutaEnLista;
            } catch (e) {
              rutaParaMostrar = _rutaSeleccionada;
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ruta:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grayMedium),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Ruta>(
                    value: rutaParaMostrar,
                    isExpanded: true,
                    hint: const Text('Selecciona una ruta'),
                    items: provider.rutas.map((ruta) {
                      return DropdownMenuItem<Ruta>(
                        value: ruta,
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: ruta.colorMapa != null
                                    ? _parseColor(ruta.colorMapa!)
                                    : AppColors.blueLight,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ruta.nombre,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (ruta) {
                      if (ruta == null) return;
                      setState(() {
                        _rutaSeleccionada = ruta;
                        if (widget.registroPrevio != null && 
                            ruta.idRuta == widget.registroPrevio!.idRuta &&
                            ruta.puntos.isNotEmpty) {
                          try {
                            _paraderoSeleccionado = ruta.puntos.firstWhere(
                              (p) => p.idPunto == widget.registroPrevio!.idParadero,
                            );
                          } catch (e) {
                            _paraderoSeleccionado = ruta.puntos.first;
                          }
                        } else {
                          _paraderoSeleccionado = null;
                        }
                      });
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildParaderoSelector() {
    if (_rutaSeleccionada == null || _rutaSeleccionada!.puntos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Paradero:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grayMedium),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<RoutePoint>(
              value: _paraderoSeleccionado,
              isExpanded: true,
              hint: const Text('Selecciona un paradero'),
              items: _rutaSeleccionada!.puntos.map((punto) {
                return DropdownMenuItem<RoutePoint>(
                  value: punto,
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: AppColors.blueLight,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          punto.name ?? 'Paradero ${punto.order ?? ''}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (paradero) {
                setState(() {
                  _paraderoSeleccionado = paradero;
                });
              },
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }

  bool _puedeRegistrar() {
    return _rutaSeleccionada != null &&
        _paraderoSeleccionado != null &&
        _paraderoSeleccionado!.idPunto != null;
  }

  Future<void> _registrarRutaParadero(
      BuildContext context, String? token) async {
    if (!_puedeRegistrar()) return;

    setState(() => _isRegistrando = true);

    try {
      final useCase = RegistrarRutaParaderoUseCase(
        RegistroRutaRepositoryImpl(),
      );

      await useCase(
        idRuta: _rutaSeleccionada!.idRuta,
        idParadero: _paraderoSeleccionado!.idPunto!,
        token: token,
      );

      if (mounted) {
        AppToast.show(
          context,
          message: 'Ruta y paradero registrados correctamente',
          type: ToastType.success,
        );
        widget.onRegistroCompletado?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Error al registrar: ${e.toString()}',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegistrando = false);
      }
    }
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return AppColors.blueLight;
    }
  }
}

