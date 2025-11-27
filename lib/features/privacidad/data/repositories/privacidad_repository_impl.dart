import '../../domain/entities/version_privacidad.dart';
import '../../domain/repositories/privacidad_repository.dart';
import '../datasources/privacidad_remote_data_source.dart';

class PrivacidadRepositoryImpl implements PrivacidadRepository {
  PrivacidadRepositoryImpl({
    PrivacidadRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? PrivacidadRemoteDataSource();

  final PrivacidadRemoteDataSource _remoteDataSource;

  @override
  Future<VersionPrivacidad> obtenerVersionActual() async {
    return await _remoteDataSource.fetchVersionActual();
  }
}

