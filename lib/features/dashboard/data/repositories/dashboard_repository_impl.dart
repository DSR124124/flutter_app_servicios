import '../../../../core/errors/app_exception.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/perfil_info.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({
    required AuthRepository authRepository,
    DashboardRemoteDataSource? remoteDataSource,
  }) : _authRepository = authRepository,
       _remoteDataSource = remoteDataSource ?? DashboardRemoteDataSource();

  final AuthRepository _authRepository;
  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Future<PerfilInfo> obtenerPerfil() async {
    final user = await _authRepository.getCurrentUser();
    final token = user?.token;

    if (token == null || token.isEmpty) {
      throw AppException.sessionExpired();
    }

    final data = await _remoteDataSource.fetchPerfil(token: token);
    return PerfilInfo.fromMap(data);
  }
}
