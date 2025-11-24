class Servicio {
  final int idServicio;
  final String nombre;
  final String descripcion;
  final String estado;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  const Servicio({
    required this.idServicio,
    required this.nombre,
    required this.descripcion,
    required this.estado,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  factory Servicio.fromMap(Map<String, dynamic> map) {
    return Servicio(
      idServicio: map['idServicio'] as int? ?? 0,
      nombre: map['nombre'] as String? ?? '',
      descripcion: map['descripcion'] as String? ?? '',
      estado: map['estado'] as String? ?? 'ACTIVO',
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.parse(map['fechaCreacion'] as String)
          : null,
      fechaActualizacion: map['fechaActualizacion'] != null
          ? DateTime.parse(map['fechaActualizacion'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idServicio': idServicio,
      'nombre': nombre,
      'descripcion': descripcion,
      'estado': estado,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
    };
  }
}

