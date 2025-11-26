class AppConfig {
  AppConfig._();

  static const String backendGestionBaseUrl =
      'https://edugen.brianuceda.xyz/gestion';
  
  // URL del backend de servicios - producción
  static const String backendServiciosBaseUrl =
      'https://edugen.brianuceda.xyz/servicios';

  static const String loginEndpoint = '/api/auth/login';
  
  /// Código único de identificación de la aplicación
  /// Este código debe coincidir con el codigoProducto registrado en la tabla aplicaciones
  /// del backend-gestion. Debe ser único y no cambiar una vez registrado.
  static const String appCode = 'FLUTTER_APP_SERVICIOS';
  
  /// Versión actual de la aplicación (debe coincidir con pubspec.yaml)
  static const String appVersion = '1.0.0';
  
  /// Endpoint para verificar actualizaciones disponibles
  /// Formato: /api/verificar-actualizacion/{idUsuario}/{codigoProducto}/{versionActual}
  static const String updateCheckEndpoint = '/api/verificar-actualizacion';
  
  /// URL del webhook de n8n Chat
  static const String n8nChatWebhookUrl = 
      'https://edugen.brianuceda.xyz/n8n/webhook/a4c3bcec-d52e-48c2-a183-54746be88300/chat';
}
