import '../entities/version_terminos.dart';

abstract class TerminosRepository {
  Future<VersionTerminos> obtenerVersionActual();
}

