import '../entities/perfil_info.dart';

abstract class DashboardRepository {
  Future<PerfilInfo> obtenerPerfil();
}
