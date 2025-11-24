import '../entities/servicio.dart';
import '../repositories/servicios_repository.dart';

class GetServiciosUseCase {
  GetServiciosUseCase(this._repository);

  final ServiciosRepository _repository;

  Future<List<Servicio>> call() {
    return _repository.obtenerServicios();
  }
}

