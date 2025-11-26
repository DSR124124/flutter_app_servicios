class VersionTerminos {
  final int idVersion;
  final String numeroVersion;
  final String titulo;
  final String contenido;
  final String? resumenCambios;
  final DateTime fechaCreacion;
  final DateTime fechaVigenciaInicio;
  final DateTime? fechaVigenciaFin;
  final bool esVersionActual;
  final String? estado;
  final int? idUsuarioCreador;
  final String? nombreUsuarioCreador;
  final DateTime? fechaModificacion;

  const VersionTerminos({
    required this.idVersion,
    required this.numeroVersion,
    required this.titulo,
    required this.contenido,
    this.resumenCambios,
    required this.fechaCreacion,
    required this.fechaVigenciaInicio,
    this.fechaVigenciaFin,
    required this.esVersionActual,
    this.estado,
    this.idUsuarioCreador,
    this.nombreUsuarioCreador,
    this.fechaModificacion,
  });

  factory VersionTerminos.fromMap(Map<String, dynamic> map) {
    return VersionTerminos(
      idVersion: map['idVersion'] as int? ?? 0,
      numeroVersion: map['numeroVersion'] as String? ?? '',
      titulo: map['titulo'] as String? ?? '',
      contenido: map['contenido'] as String? ?? '',
      resumenCambios: map['resumenCambios'] as String?,
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.parse(map['fechaCreacion'] as String)
          : DateTime.now(),
      fechaVigenciaInicio: map['fechaVigenciaInicio'] != null
          ? DateTime.parse(map['fechaVigenciaInicio'] as String)
          : DateTime.now(),
      fechaVigenciaFin: map['fechaVigenciaFin'] != null
          ? DateTime.parse(map['fechaVigenciaFin'] as String)
          : null,
      esVersionActual: map['esVersionActual'] as bool? ?? false,
      estado: map['estado'] as String?,
      idUsuarioCreador: map['idUsuarioCreador'] as int?,
      nombreUsuarioCreador: map['nombreUsuarioCreador'] as String?,
      fechaModificacion: map['fechaModificacion'] != null
          ? DateTime.parse(map['fechaModificacion'] as String)
          : null,
    );
  }
}

