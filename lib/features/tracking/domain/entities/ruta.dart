import 'route_point.dart';

/// Entidad de dominio que representa una ruta
class Ruta {
  final int idRuta;
  final String nombre;
  final String? descripcion;
  final String? colorMapa;
  final bool estado;
  final List<RoutePoint> puntos;

  const Ruta({
    required this.idRuta,
    required this.nombre,
    this.descripcion,
    this.colorMapa,
    required this.estado,
    required this.puntos,
  });
}
