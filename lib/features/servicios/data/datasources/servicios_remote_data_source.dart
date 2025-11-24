import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/constants/app_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/servicio_model.dart';

class ServiciosRemoteDataSource {
  ServiciosRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<ServicioModel>> fetchServicios({String? token}) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      // Token opcional - solo se envía si está disponible
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await _client
          .get(
            Uri.parse('${AppConfig.backendServiciosBaseUrl}/api/servicios'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.map((json) => ServicioModel.fromJson(json as Map<String, dynamic>)).toList();
      }

      if (response.statusCode == 401) {
        throw AppException.sessionExpired();
      }
      if (response.statusCode == 403) {
        throw AppException.forbidden();
      }
      if (response.statusCode >= 500) {
        throw AppException.server();
      }

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

  Future<ServicioModel> fetchServicioPorId({
    String? token,
    required int idServicio,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      // Token opcional - solo se envía si está disponible
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await _client
          .get(
            Uri.parse('${AppConfig.backendServiciosBaseUrl}/api/servicios/$idServicio'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ServicioModel.fromJson(data);
      }

      if (response.statusCode == 401) {
        throw AppException.sessionExpired();
      }
      if (response.statusCode == 403) {
        throw AppException.forbidden();
      }
      if (response.statusCode == 404) {
        throw AppException('Servicio no encontrado');
      }
      if (response.statusCode >= 500) {
        throw AppException.server();
      }

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

  Future<ServicioModel> createServicio({
    required String token,
    required ServicioModel servicio,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${AppConfig.backendServiciosBaseUrl}/api/servicios'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(servicio.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ServicioModel.fromJson(data);
      }

      if (response.statusCode == 401) {
        throw AppException.sessionExpired();
      }
      if (response.statusCode == 403) {
        throw AppException.forbidden();
      }
      if (response.statusCode >= 500) {
        throw AppException.server();
      }

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

  Future<ServicioModel> updateServicio({
    required String token,
    required ServicioModel servicio,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse('${AppConfig.backendServiciosBaseUrl}/api/servicios/${servicio.idServicio}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(servicio.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ServicioModel.fromJson(data);
      }

      if (response.statusCode == 401) {
        throw AppException.sessionExpired();
      }
      if (response.statusCode == 403) {
        throw AppException.forbidden();
      }
      if (response.statusCode == 404) {
        throw AppException('Servicio no encontrado');
      }
      if (response.statusCode >= 500) {
        throw AppException.server();
      }

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

  Future<void> deleteServicio({
    required String token,
    required int idServicio,
  }) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('${AppConfig.backendServiciosBaseUrl}/api/servicios/$idServicio'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      if (response.statusCode == 401) {
        throw AppException.sessionExpired();
      }
      if (response.statusCode == 403) {
        throw AppException.forbidden();
      }
      if (response.statusCode == 404) {
        throw AppException('Servicio no encontrado');
      }
      if (response.statusCode >= 500) {
        throw AppException.server();
      }

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

