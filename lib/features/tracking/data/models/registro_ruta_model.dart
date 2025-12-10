import '../../domain/entities/registro_ruta.dart';

/// Modelo de datos para el registro de ruta y paradero
class RegistroRutaModel extends RegistroRuta {
  const RegistroRutaModel({
    required super.idRegistro,
    required super.idUsuario,
    required super.idRuta,
    required super.nombreRuta,
    required super.idParadero,
    required super.nombreParadero,
    required super.fechaRegistro,
    required super.mensaje,
  });

  factory RegistroRutaModel.fromJson(Map<String, dynamic> json) {
    return RegistroRutaModel(
      idRegistro: json['idRegistro'] as int,
      idUsuario: json['idUsuario'] as int,
      idRuta: json['idRuta'] as int,
      nombreRuta: json['nombreRuta'] as String,
      idParadero: json['idParadero'] as int,
      nombreParadero: json['nombreParadero'] as String,
      fechaRegistro: DateTime.parse(json['fechaRegistro'] as String),
      mensaje: json['mensaje'] as String? ?? 'Registro guardado exitosamente',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idRegistro': idRegistro,
      'idUsuario': idUsuario,
      'idRuta': idRuta,
      'nombreRuta': nombreRuta,
      'idParadero': idParadero,
      'nombreParadero': nombreParadero,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'mensaje': mensaje,
    };
  }
}

