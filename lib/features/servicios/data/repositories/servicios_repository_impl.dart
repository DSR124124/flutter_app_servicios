import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/servicio.dart';
import '../../domain/repositories/servicios_repository.dart';
import '../datasources/servicios_remote_data_source.dart';
import '../models/servicio_model.dart';

class ServiciosRepositoryImpl implements ServiciosRepository {
  ServiciosRepositoryImpl({
    required AuthRepository authRepository,
    ServiciosRemoteDataSource? remoteDataSource,
  }) : _authRepository = authRepository,
       _remoteDataSource = remoteDataSource ?? ServiciosRemoteDataSource();

  final AuthRepository _authRepository;
  final ServiciosRemoteDataSource _remoteDataSource;

  String? _getToken() {
    final user = _authRepository.cachedUser;
    return user?.token;
  }

  @override
  Future<List<Servicio>> obtenerServicios() async {
    final token = _getToken(); // Token opcional para servicios públicos
    final servicios = await _remoteDataSource.fetchServicios(token: token);
    return servicios;
  }

  @override
  Future<Servicio> obtenerServicioPorId(int idServicio) async {
    final token = _getToken(); // Token opcional para servicios públicos
    return await _remoteDataSource.fetchServicioPorId(
      token: token,
      idServicio: idServicio,
    );
  }

  @override
  Future<Servicio> crearServicio(Servicio servicio) async {
    final token = _getToken();
    final servicioModel = ServicioModel.fromEntity(servicio);
    return await _remoteDataSource.createServicio(
      token: token!,
      servicio: servicioModel,
    );
  }

  @override
  Future<Servicio> actualizarServicio(Servicio servicio) async {
    final token = _getToken();
    final servicioModel = ServicioModel.fromEntity(servicio);
    return await _remoteDataSource.updateServicio(
      token: token!,
      servicio: servicioModel,
    );
  }

  @override
  Future<void> eliminarServicio(int idServicio) async {
    final token = _getToken();
    await _remoteDataSource.deleteServicio(
      token: token!,
      idServicio: idServicio,
    );
  }
}

