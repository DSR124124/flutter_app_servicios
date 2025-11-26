import '../entities/version_terminos.dart';
import '../repositories/terminos_repository.dart';

class GetVersionActualUseCase {
  GetVersionActualUseCase(this._repository);

  final TerminosRepository _repository;

  Future<VersionTerminos> call() {
    return _repository.obtenerVersionActual();
  }
}

