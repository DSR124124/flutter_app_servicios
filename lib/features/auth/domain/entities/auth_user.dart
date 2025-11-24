class AuthUser {
  final int idUsuario;
  final String username;
  final String rol;
  final String token;

  const AuthUser({
    required this.idUsuario,
    required this.username,
    required this.rol,
    required this.token,
  });
}
