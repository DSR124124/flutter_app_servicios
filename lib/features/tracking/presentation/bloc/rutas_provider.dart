import 'package:flutter/material.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/ruta.dart';
import '../../domain/repositories/rutas_repository.dart';

class RutasProvider extends ChangeNotifier {
  RutasProvider({required RutasRepository repository})
      : _repository = repository;

  final RutasRepository _repository;

  bool _isLoading = true; // Iniciar en true para mostrar spinner
  String? _error;
  List<Ruta> _rutas = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Ruta> get rutas => _rutas;

  Future<void> cargarRutas({String? token}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Delay mínimo para que el spinner sea visible
      final results = await Future.wait([
        _repository.obtenerRutas(token: token),
        Future.delayed(const Duration(milliseconds: 500)),
      ]);
      _rutas = results[0] as List<Ruta>;
      _error = null;
    } on AppException catch (e) {
      _error = e.message;
      _rutas = [];
    } catch (e) {
      _error = 'Error al cargar las rutas';
      _rutas = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
