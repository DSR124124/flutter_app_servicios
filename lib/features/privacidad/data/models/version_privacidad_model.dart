import '../../domain/entities/version_privacidad.dart';

class VersionPrivacidadModel extends VersionPrivacidad {
  const VersionPrivacidadModel({
    required super.idVersion,
    required super.numeroVersion,
    required super.titulo,
    required super.contenido,
    super.resumenCambios,
    required super.fechaCreacion,
    required super.fechaVigenciaInicio,
    super.fechaVigenciaFin,
    required super.esVersionActual,
    super.estado,
    super.idUsuarioCreador,
    super.nombreUsuarioCreador,
    super.fechaModificacion,
  });

  factory VersionPrivacidadModel.fromJson(Map<String, dynamic> json) {
    return VersionPrivacidadModel(
      idVersion: json['idVersion'] as int,
      numeroVersion: json['numeroVersion'] as String,
      titulo: json['titulo'] as String,
      contenido: json['contenido'] as String,
      resumenCambios: json['resumenCambios'] as String?,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      fechaVigenciaInicio: DateTime.parse(json['fechaVigenciaInicio'] as String),
      fechaVigenciaFin: json['fechaVigenciaFin'] != null
          ? DateTime.parse(json['fechaVigenciaFin'] as String)
          : null,
      esVersionActual: json['esVersionActual'] as bool,
      estado: json['estado'] as String?,
      idUsuarioCreador: json['idUsuarioCreador'] as int?,
      nombreUsuarioCreador: json['nombreUsuarioCreador'] as String?,
      fechaModificacion: json['fechaModificacion'] != null
          ? DateTime.parse(json['fechaModificacion'] as String)
          : null,
    );
  }
}

