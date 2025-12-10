import '../entities/registro_ruta.dart';
import '../repositories/registro_ruta_repository.dart';

class RegistrarRutaParaderoUseCase {
  RegistrarRutaParaderoUseCase(this._repository);

  final RegistroRutaRepository _repository;

  Future<RegistroRuta> call({
    required int idRuta,
    required int idParadero,
    String? observacion,
    String? token,
  }) {
    return _repository.registrarRutaParadero(
      idRuta: idRuta,
      idParadero: idParadero,
      observacion: observacion,
      token: token,
    );
  }
}

class ObtenerUltimoRegistroUseCase {
  ObtenerUltimoRegistroUseCase(this._repository);

  final RegistroRutaRepository _repository;

  Future<RegistroRuta?> call({String? token}) {
    return _repository.obtenerUltimoRegistro(token: token);
  }
}

