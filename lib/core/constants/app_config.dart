import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const String backendGestionBaseUrl =
      'https://edugen.brianuceda.xyz/gestion';
  
  // Detectar automáticamente la URL correcta según la plataforma
  static String get backendServiciosBaseUrl {
    if (kIsWeb) {
      // Para web, usar localhost
      return 'http://localhost:8081';
    } else if (Platform.isAndroid) {
      // Para Android (emulador o dispositivo físico), usar 10.0.2.2 para emulador
      // Si estás en dispositivo físico, necesitarás la IP de tu máquina
      return 'http://10.0.2.2:8081';
    } else if (Platform.isIOS) {
      // Para iOS, usar localhost
      return 'http://localhost:8081';
    } else {
      // Por defecto, localhost
      return 'http://localhost:8081';
    }
  }
  
  // Si estás usando un dispositivo físico Android, descomenta y usa tu IP local:
  // static const String backendServiciosBaseUrl = 'http://192.168.1.XXX:8081';
  
  // Para producción:
  // static const String backendServiciosBaseUrl = 'http://154.38.186.149:8080';

  static const String loginEndpoint = '/api/auth/login';
  
  /// Código único de identificación de la aplicación
  /// Este código debe coincidir con el codigoProducto registrado en la tabla aplicaciones
  /// del backend-gestion. Debe ser único y no cambiar una vez registrado.
  static const String appCode = 'FLUTTER_APP_SERVICIOS';
  
  /// URL del webhook de n8n Chat
  static const String n8nChatWebhookUrl = 
      'https://edugen.brianuceda.xyz/n8n/webhook/a4c3bcec-d52e-48c2-a183-54746be88300/chat';
}
