import '../../domain/entities/ruta.dart';
import '../../domain/entities/route_point.dart';

class RutaModel extends Ruta {
  const RutaModel({
    required super.idRuta,
    required super.nombre,
    super.descripcion,
    super.colorMapa,
    required super.estado,
    required super.puntos,
  });

  factory RutaModel.fromJson(Map<String, dynamic> json) {
    final puntosList = json['puntos'] as List<dynamic>? ?? [];
    final puntos = puntosList
        .map((p) => RoutePoint.fromMap(p as Map<String, dynamic>))
        .toList();
    
    // Ordenar puntos por orden (si tienen orden definido)
    puntos.sort((a, b) {
      final orderA = a.order ?? 0;
      final orderB = b.order ?? 0;
      return orderA.compareTo(orderB);
    });
    
    return RutaModel(
      idRuta: (json['idRuta'] as num?)?.toInt() ?? 0,
      nombre: json['nombre'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
      colorMapa: json['colorMapa'] as String?,
      estado: (json['estado'] as bool?) ?? true,
      puntos: puntos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idRuta': idRuta,
      'nombre': nombre,
      'descripcion': descripcion,
      'colorMapa': colorMapa,
      'estado': estado,
      'puntos': puntos.map((p) => p.toMap()).toList(),
    };
  }

  factory RutaModel.fromEntity(Ruta entity) {
    return RutaModel(
      idRuta: entity.idRuta,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      colorMapa: entity.colorMapa,
      estado: entity.estado,
      puntos: entity.puntos,
    );
  }
}
