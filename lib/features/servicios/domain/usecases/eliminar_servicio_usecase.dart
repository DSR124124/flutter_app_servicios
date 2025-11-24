import '../repositories/servicios_repository.dart';

class EliminarServicioUseCase {
  EliminarServicioUseCase(this._repository);

  final ServiciosRepository _repository;

  Future<void> call(int idServicio) {
    return _repository.eliminarServicio(idServicio);
  }
}

