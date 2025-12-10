import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/constants/app_config.dart';
import '../../../../core/errors/app_exception.dart';

class RegistroRutaRemoteDataSource {
  RegistroRutaRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> _buildHeaders(String? token) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> registrarRutaParadero({
    required int idRuta,
    required int idParadero,
    String? observacion,
    String? token,
  }) async {
    try {
      final body = jsonEncode({
        'idRuta': idRuta,
        'idParadero': idParadero,
        if (observacion != null && observacion.isNotEmpty) 'observacion': observacion,
      });

      final response = await _client
          .post(
            Uri.parse('${AppConfig.backendServiciosBaseUrl}/api/registro-ruta'),
            headers: _buildHeaders(token),
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      if (response.statusCode == 401) throw AppException.sessionExpired();
      if (response.statusCode == 403) throw AppException.forbidden();
      if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
        throw AppException(errorBody['error'] as String? ?? 'Error en la solicitud');
      }
      if (response.statusCode >= 500) throw AppException.server();
      throw AppException.unknown();
    } on SocketException catch (_, stackTrace) {
      throw AppException.network(stackTrace);
    } on TimeoutException catch (_, stackTrace) {
      throw AppException.timeout(stackTrace);
    } on AppException {
      rethrow;
    } catch (_, stackTrace) {
      throw AppException.unknown(stackTrace);
    }
  }

  Future<Map<String, dynamic>?> obtenerUltimoRegistro({String? token}) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConfig.backendServiciosBaseUrl}/api/registro-ruta/ultimo'),
            headers: _buildHeaders(token),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      if (response.statusCode == 401) throw AppException.sessionExpired();
      if (response.statusCode == 403) throw AppException.forbidden();
      if (response.statusCode == 404) {
        // No hay registro, retornar null
        return null;
      }
      if (response.statusCode >= 500) throw AppException.server();
      throw AppException.unknown();
    } on SocketException catch (_, stackTrace) {
      throw AppException.network(stackTrace);
    } on TimeoutException catch (_, stackTrace) {
      throw AppException.timeout(stackTrace);
    } on AppException {
      rethrow;
    } catch (_, stackTrace) {
      throw AppException.unknown(stackTrace);
    }
  }
}

