import '../../domain/entities/registro_ruta.dart';
import '../../domain/repositories/registro_ruta_repository.dart';
import '../datasources/registro_ruta_remote_data_source.dart';
import '../models/registro_ruta_model.dart';

class RegistroRutaRepositoryImpl implements RegistroRutaRepository {
  RegistroRutaRepositoryImpl({
    RegistroRutaRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? RegistroRutaRemoteDataSource();

  final RegistroRutaRemoteDataSource _remoteDataSource;

  @override
  Future<RegistroRuta> registrarRutaParadero({
    required int idRuta,
    required int idParadero,
    String? observacion,
    String? token,
  }) async {
    final json = await _remoteDataSource.registrarRutaParadero(
      idRuta: idRuta,
      idParadero: idParadero,
      observacion: observacion,
      token: token,
    );
    return RegistroRutaModel.fromJson(json);
  }

  @override
  Future<RegistroRuta?> obtenerUltimoRegistro({String? token}) async {
    final json = await _remoteDataSource.obtenerUltimoRegistro(token: token);
    if (json == null) return null;
    return RegistroRutaModel.fromJson(json);
  }
}

