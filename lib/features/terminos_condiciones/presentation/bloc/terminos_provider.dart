import 'package:flutter/material.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/version_terminos.dart';
import '../../domain/usecases/get_version_actual_usecase.dart';

class TerminosProvider extends ChangeNotifier {
  TerminosProvider({
    required GetVersionActualUseCase getVersionActualUseCase,
  }) : _getVersionActualUseCase = getVersionActualUseCase;

  final GetVersionActualUseCase _getVersionActualUseCase;

  VersionTerminos? _versionActual;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _error;

  VersionTerminos? get versionActual => _versionActual;
  bool get isLoading => _isLoading;
  bool get isInitialLoading => _isInitialLoading;
  String? get error => _error;

  Future<void> loadVersionActual() async {
    _isLoading = true;
    _isInitialLoading = _versionActual == null;
    _error = null;
    notifyListeners();

    try {
      _versionActual = await _getVersionActualUseCase();
      _error = null;
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = AppException.unknown().message;
    } finally {
      _isLoading = false;
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  void loadVersionActualSilently() {
    if (_versionActual == null && !_isLoading) {
      loadVersionActual();
    }
  }
}

