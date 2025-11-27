import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/constants/app_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/version_privacidad_model.dart';

class PrivacidadRemoteDataSource {
  PrivacidadRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<VersionPrivacidadModel> fetchVersionActual() async {
    try {
      final response = await _client
          .get(
            Uri.parse(
              '${AppConfig.backendServiciosBaseUrl}/api/versiones-privacidad/actual',
            ),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return VersionPrivacidadModel.fromJson(data);
      }

      if (response.statusCode == 404) {
        throw AppException('No se encontró la versión actual de política de privacidad');
      }

      throw AppException.server();
    } on SocketException catch (_, stackTrace) {
      throw AppException.network(stackTrace);
    } on TimeoutException catch (_, stackTrace) {
      throw AppException.timeout(stackTrace);
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      throw AppException.unknown(stackTrace);
    }
  }
}

