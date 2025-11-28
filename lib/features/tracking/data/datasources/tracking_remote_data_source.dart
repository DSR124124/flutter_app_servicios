import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/constants/app_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/bus_location_model.dart';
import '../models/trip_detail_model.dart';

/// Data source remoto para tracking
/// 
/// NOTA: Para implementación con Supabase Realtime, deberías usar:
/// - supabase_flutter para WebSocket connections
/// - O implementar un StreamController que se actualice desde WebSocket
class TrackingRemoteDataSource {
  TrackingRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> _buildHeaders(String? token) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<TripDetailModel> fetchTripRoute({
    required int tripId,
    String? token,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConfig.backendServiciosBaseUrl}/api/trips/$tripId/route'),
            headers: _buildHeaders(token),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return TripDetailModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }

      if (response.statusCode == 401) throw AppException.sessionExpired();
      if (response.statusCode == 403) throw AppException.forbidden();
      if (response.statusCode == 404) throw AppException('Viaje no encontrado');
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

  Future<BusLocationModel> fetchCurrentBusLocation({
    required int tripId,
    String? token,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConfig.backendServiciosBaseUrl}/api/trips/$tripId/location'),
            headers: _buildHeaders(token),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return BusLocationModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }

      if (response.statusCode == 401) throw AppException.sessionExpired();
      if (response.statusCode == 403) throw AppException.forbidden();
      if (response.statusCode == 404) throw AppException('Ubicación no encontrada');
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

  /// Crea un Stream que emite actualizaciones de ubicación
  /// 
  /// IMPLEMENTACIÓN: 
  /// - Para Supabase Realtime: usa supabase_flutter y suscribe a cambios
  /// - Para WebSocket: implementa un WebSocket client
  /// - Para polling: usa Timer.periodic con fetchCurrentBusLocation
  /// 
  /// Esta es una implementación de ejemplo con polling (fallback)
  Stream<BusLocationModel> listenBusLocationStream({
    required int tripId,
    String? token,
    Duration pollInterval = const Duration(seconds: 5),
  }) async* {
    // Implementación con polling como ejemplo
    // En producción, reemplaza esto con WebSocket/Supabase Realtime
    while (true) {
      try {
        final location = await fetchCurrentBusLocation(
          tripId: tripId,
          token: token,
        );
        yield location;
        await Future.delayed(pollInterval);
      } catch (e) {
        // En caso de error, esperar un poco antes de reintentar
        await Future.delayed(pollInterval);
        // Opcional: re-lanzar el error o manejarlo según tu lógica
      }
    }
  }
}

