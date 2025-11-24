import '../../domain/entities/servicio.dart';

class ServicioModel extends Servicio {
  const ServicioModel({
    required super.idServicio,
    required super.nombre,
    required super.descripcion,
    required super.estado,
    super.fechaCreacion,
    super.fechaActualizacion,
  });

  factory ServicioModel.fromJson(Map<String, dynamic> json) {
    return ServicioModel(
      idServicio: json['idServicio'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      estado: json['estado'] as String? ?? 'ACTIVO',
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'] as String)
          : null,
      fechaActualizacion: json['fechaActualizacion'] != null
          ? DateTime.parse(json['fechaActualizacion'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idServicio': idServicio,
      'nombre': nombre,
      'descripcion': descripcion,
      'estado': estado,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  factory ServicioModel.fromEntity(Servicio servicio) {
    return ServicioModel(
      idServicio: servicio.idServicio,
      nombre: servicio.nombre,
      descripcion: servicio.descripcion,
      estado: servicio.estado,
      fechaCreacion: servicio.fechaCreacion,
      fechaActualizacion: servicio.fechaActualizacion,
    );
  }
}

