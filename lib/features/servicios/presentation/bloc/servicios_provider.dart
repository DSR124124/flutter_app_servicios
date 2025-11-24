import 'package:flutter/material.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/servicio.dart';
import '../../domain/usecases/actualizar_servicio_usecase.dart';
import '../../domain/usecases/crear_servicio_usecase.dart';
import '../../domain/usecases/eliminar_servicio_usecase.dart';
import '../../domain/usecases/get_servicio_por_id_usecase.dart';
import '../../domain/usecases/get_servicios_usecase.dart';

class ServiciosProvider extends ChangeNotifier {
  ServiciosProvider({
    required GetServiciosUseCase getServiciosUseCase,
    required GetServicioPorIdUseCase getServicioPorIdUseCase,
    required CrearServicioUseCase crearServicioUseCase,
    required ActualizarServicioUseCase actualizarServicioUseCase,
    required EliminarServicioUseCase eliminarServicioUseCase,
  })  : _getServiciosUseCase = getServiciosUseCase,
        _getServicioPorIdUseCase = getServicioPorIdUseCase,
        _crearServicioUseCase = crearServicioUseCase,
        _actualizarServicioUseCase = actualizarServicioUseCase,
        _eliminarServicioUseCase = eliminarServicioUseCase {
    _loadServiciosSilently();
  }

  final GetServiciosUseCase _getServiciosUseCase;
  final GetServicioPorIdUseCase _getServicioPorIdUseCase;
  final CrearServicioUseCase _crearServicioUseCase;
  final ActualizarServicioUseCase _actualizarServicioUseCase;
  final EliminarServicioUseCase _eliminarServicioUseCase;

  List<Servicio> _servicios = [];
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _error;

  List<Servicio> get servicios => _servicios;
  bool get isLoading => _isLoading;
  bool get isInitialLoading => _isInitialLoading;
  String? get error => _error;
  bool get hasServicios => _servicios.isNotEmpty;

  Future<void> _loadServiciosSilently() async {
    // Carga inicial sin mostrar spinner modal
    try {
      _servicios = await _getServiciosUseCase();
      _error = null;
    } on AppException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = AppException.unknown().message;
    } finally {
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadServicios() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _servicios = await _getServiciosUseCase();
    } on AppException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = AppException.unknown().message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Servicio?> loadServicioPorId(int idServicio) async {
    try {
      return await _getServicioPorIdUseCase(idServicio);
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      _error = AppException.unknown().message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> crearServicio(Servicio servicio) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final nuevoServicio = await _crearServicioUseCase(servicio);
      _servicios.add(nuevoServicio);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = AppException.unknown().message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarServicio(Servicio servicio) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final servicioActualizado = await _actualizarServicioUseCase(servicio);
      final index = _servicios.indexWhere((s) => s.idServicio == servicio.idServicio);
      if (index != -1) {
        _servicios[index] = servicioActualizado;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = AppException.unknown().message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarServicio(int idServicio) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _eliminarServicioUseCase(idServicio);
      _servicios.removeWhere((s) => s.idServicio == idServicio);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = AppException.unknown().message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

