import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/ruta.dart';
import '../../domain/repositories/rutas_repository.dart';
import '../datasources/rutas_remote_data_source.dart';
import '../models/ruta_model.dart';
import '../models/ruta_completa_model.dart';

class RutasRepositoryImpl implements RutasRepository {
  RutasRepositoryImpl({
    RutasRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
            remoteDataSource ?? RutasRemoteDataSource();

  final RutasRemoteDataSource _remoteDataSource;

  @override
  Future<List<Ruta>> obtenerRutas({String? token}) async {
    try {
      final models = await _remoteDataSource.fetchRutas(token: token);
      return models.map((model) => model as Ruta).toList();
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw AppException.unknown(stackTrace);
    }
  }

  @override
  Future<Ruta> obtenerRutaPorId(int idRuta, {String? token}) async {
    try {
      final model = await _remoteDataSource.fetchRutaPorId(idRuta, token: token);
      return model as Ruta;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw AppException.unknown(stackTrace);
    }
  }

  /// Obtiene el detalle completo de una ruta (optimizado - una sola llamada)
  Future<RutaCompletaModel> obtenerRutaCompleta(int idRuta, {String? token}) async {
    try {
      final json = await _remoteDataSource.fetchRutaCompleta(idRuta, token: token);
      return RutaCompletaModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw AppException.unknown(stackTrace);
    }
  }
}
