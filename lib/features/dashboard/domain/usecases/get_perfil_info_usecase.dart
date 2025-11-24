import '../entities/perfil_info.dart';
import '../repositories/dashboard_repository.dart';

class GetPerfilInfoUseCase {
  GetPerfilInfoUseCase(this._repository);

  final DashboardRepository _repository;

  Future<PerfilInfo> call() {
    return _repository.obtenerPerfil();
  }
}
