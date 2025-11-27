import '../entities/version_privacidad.dart';
import '../repositories/privacidad_repository.dart';

class GetVersionActualUseCase {
  GetVersionActualUseCase(this._repository);

  final PrivacidadRepository _repository;

  Future<VersionPrivacidad> call() {
    return _repository.obtenerVersionActual();
  }
}

