import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/constants/app_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/ruta_model.dart';

/// Data source remoto para obtener rutas
class RutasRemoteDataSource {
  RutasRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> _buildHeaders(String? token) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<RutaModel>> fetchRutas({String? token}) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConfig.backendServiciosBaseUrl}/api/rutas'),
            headers: _buildHeaders(token),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
        return jsonList
            .map((json) => RutaModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      if (response.statusCode == 401) throw AppException.sessionExpired();
      if (response.statusCode == 403) throw AppException.forbidden();
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

  Future<RutaModel> fetchRutaPorId(int idRuta, {String? token}) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConfig.backendServiciosBaseUrl}/api/rutas/$idRuta'),
            headers: _buildHeaders(token),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return RutaModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }

      if (response.statusCode == 401) throw AppException.sessionExpired();
      if (response.statusCode == 403) throw AppException.forbidden();
      if (response.statusCode == 404) throw AppException('Ruta no encontrada');
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

  /// Obtiene el detalle completo de una ruta (ruta + viajes activos + horarios)
  /// Endpoint optimizado que reduce múltiples llamadas
  Future<Map<String, dynamic>> fetchRutaCompleta(int idRuta, {String? token}) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConfig.backendServiciosBaseUrl}/api/rutas/$idRuta/completo'),
            headers: _buildHeaders(token),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      if (response.statusCode == 401) throw AppException.sessionExpired();
      if (response.statusCode == 403) throw AppException.forbidden();
      if (response.statusCode == 404) throw AppException('Ruta no encontrada');
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
