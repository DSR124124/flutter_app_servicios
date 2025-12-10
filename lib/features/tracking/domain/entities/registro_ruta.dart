class RegistroRuta {
  final int idRegistro;
  final int idUsuario;
  final int idRuta;
  final String nombreRuta;
  final int idParadero;
  final String nombreParadero;
  final DateTime fechaRegistro;
  final String mensaje;

  const RegistroRuta({
    required this.idRegistro,
    required this.idUsuario,
    required this.idRuta,
    required this.nombreRuta,
    required this.idParadero,
    required this.nombreParadero,
    required this.fechaRegistro,
    required this.mensaje,
  });

  factory RegistroRuta.fromJson(Map<String, dynamic> json) {
    return RegistroRuta(
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
}

