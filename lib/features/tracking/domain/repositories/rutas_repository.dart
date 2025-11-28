import '../entities/ruta.dart';
import '../../data/models/ruta_completa_model.dart';

abstract class RutasRepository {
  Future<List<Ruta>> obtenerRutas({String? token});
  Future<Ruta> obtenerRutaPorId(int idRuta, {String? token});
  Future<RutaCompletaModel> obtenerRutaCompleta(int idRuta, {String? token});
}
