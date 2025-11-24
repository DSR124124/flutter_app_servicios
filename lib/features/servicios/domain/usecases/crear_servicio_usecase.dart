import '../entities/servicio.dart';
import '../repositories/servicios_repository.dart';

class CrearServicioUseCase {
  CrearServicioUseCase(this._repository);

  final ServiciosRepository _repository;

  Future<Servicio> call(Servicio servicio) {
    return _repository.crearServicio(servicio);
  }
}

