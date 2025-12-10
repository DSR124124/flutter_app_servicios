import '../entities/registro_ruta.dart';

abstract class RegistroRutaRepository {
  Future<RegistroRuta> registrarRutaParadero({
    required int idRuta,
    required int idParadero,
    String? observacion,
    String? token,
  });

  Future<RegistroRuta?> obtenerUltimoRegistro({String? token});
}

