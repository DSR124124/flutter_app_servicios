import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../errors/app_exception.dart';

/// Cliente HTTP configurado para la aplicación
class HttpClient {
  final http.Client _client;
  final Duration timeout;

  HttpClient({
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  /// Realiza una petición GET
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw AppException.network();
    } on http.ClientException {
      throw AppException('Error de conexión con el servidor');
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  /// Realiza una petición POST
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              ...?headers,
            },
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw AppException.network();
    } on http.ClientException {
      throw AppException('Error de conexión con el servidor');
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  /// Realiza una petición PUT
  Future<Map<String, dynamic>> put(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              ...?headers,
            },
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw AppException.network();
    } on http.ClientException {
      throw AppException('Error de conexión con el servidor');
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  /// Realiza una petición DELETE
  Future<Map<String, dynamic>> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .delete(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw AppException.network();
    } on http.ClientException {
      throw AppException('Error de conexión con el servidor');
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  /// Maneja la respuesta HTTP
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    // Manejo de errores
    String errorMessage = 'Error del servidor';
    
    try {
      final errorBody = jsonDecode(response.body);
      errorMessage = errorBody['message'] ?? errorBody['error'] ?? errorMessage;
    } catch (_) {
      // Si no se puede decodificar, usar mensaje por defecto
    }

    switch (response.statusCode) {
      case 400:
        throw AppException(errorMessage);
      case 401:
        throw AppException.unauthorized();
      case 403:
        throw AppException.forbidden();
      case 404:
        throw AppException('Recurso no encontrado');
      case 500:
      case 502:
      case 503:
        throw AppException.server();
      default:
        throw AppException(errorMessage);
    }
  }

  /// Cierra el cliente
  void close() {
    _client.close();
  }
}

