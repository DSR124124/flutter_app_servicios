import '../entities/servicio.dart';
import '../repositories/servicios_repository.dart';

class GetServicioPorIdUseCase {
  GetServicioPorIdUseCase(this._repository);

  final ServiciosRepository _repository;

  Future<Servicio> call(int idServicio) {
    return _repository.obtenerServicioPorId(idServicio);
  }
}

