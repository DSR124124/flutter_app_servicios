import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.idUsuario,
    required super.username,
    required super.rol,
    required super.token,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final usuarioJson = json['usuario'] as Map<String, dynamic>? ?? {};
    return AuthUserModel(
      idUsuario: usuarioJson['idUsuario'] as int? ?? 0,
      username: usuarioJson['username'] as String? ?? '',
      rol: usuarioJson['rol'] as String? ?? '',
      token: json['token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'usuario': {'idUsuario': idUsuario, 'username': username, 'rol': rol},
    };
  }
}
