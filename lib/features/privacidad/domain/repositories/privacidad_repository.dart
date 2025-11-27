import '../entities/version_privacidad.dart';

abstract class PrivacidadRepository {
  Future<VersionPrivacidad> obtenerVersionActual();
}

