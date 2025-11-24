import '../entities/servicio.dart';

abstract class ServiciosRepository {
  Future<List<Servicio>> obtenerServicios();
  Future<Servicio> obtenerServicioPorId(int idServicio);
  Future<Servicio> crearServicio(Servicio servicio);
  Future<Servicio> actualizarServicio(Servicio servicio);
  Future<void> eliminarServicio(int idServicio);
}

