import '../../domain/entities/version_terminos.dart';
import '../../domain/repositories/terminos_repository.dart';
import '../datasources/terminos_remote_data_source.dart';

class TerminosRepositoryImpl implements TerminosRepository {
  TerminosRepositoryImpl({
    TerminosRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? TerminosRemoteDataSource();

  final TerminosRemoteDataSource _remoteDataSource;

  @override
  Future<VersionTerminos> obtenerVersionActual() async {
    return await _remoteDataSource.fetchVersionActual();
  }
}

