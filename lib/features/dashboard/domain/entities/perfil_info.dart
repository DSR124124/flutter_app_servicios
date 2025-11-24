class PerfilInfo {
  final int idUsuario;
  final String username;
  final String rol;
  final String mensaje;

  const PerfilInfo({
    required this.idUsuario,
    required this.username,
    required this.rol,
    required this.mensaje,
  });

  factory PerfilInfo.fromMap(Map<String, dynamic> map) {
    return PerfilInfo(
      idUsuario: map['idUsuario'] as int? ?? 0,
      username: map['username'] as String? ?? '',
      rol: map['rol'] as String? ?? '',
      mensaje: map['mensaje'] as String? ?? '',
    );
  }
}
