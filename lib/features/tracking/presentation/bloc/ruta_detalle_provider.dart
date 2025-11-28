import 'package:flutter/material.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/ruta.dart';
import '../../domain/repositories/rutas_repository.dart';
import '../../data/models/ruta_completa_model.dart' show RutaCompletaModel, ViajeActivoModel, HorarioModel;

class RutaDetalleProvider extends ChangeNotifier {
  RutaDetalleProvider({required RutasRepository repository})
      : _repository = repository;

  final RutasRepository _repository;

  bool _isLoading = true; // Iniciar en true para mostrar spinner
  String? _error;
  Ruta? _ruta;
  RutaCompletaModel? _rutaCompleta;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Ruta? get ruta => _ruta;
  RutaCompletaModel? get rutaCompleta => _rutaCompleta;
  
  List<ViajeActivoModel> get viajesActivos => _rutaCompleta?.viajesActivos ?? [];
  List<HorarioModel> get horarios => _rutaCompleta?.horarios ?? [];

  Future<void> cargarRuta(int idRuta, {String? token}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Delay mínimo para que el spinner sea visible
      final results = await Future.wait([
        _repository.obtenerRutaCompleta(idRuta, token: token),
        Future.delayed(const Duration(milliseconds: 500)),
      ]);
      _rutaCompleta = results[0] as RutaCompletaModel;
      _ruta = _rutaCompleta!.ruta;
      _error = null;
    } on AppException catch (e) {
      _error = e.message;
      _ruta = null;
      _rutaCompleta = null;
    } catch (e) {
      _error = 'Error al cargar la ruta';
      _ruta = null;
      _rutaCompleta = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
