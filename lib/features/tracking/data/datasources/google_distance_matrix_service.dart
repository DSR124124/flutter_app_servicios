import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

/// Servicio para calcular distancias y tiempos usando Distance Matrix API
class GoogleDistanceMatrixService {
  static const String _apiKey = 'AIzaSyCnJC_qbY41ZsXjgDLhTmcSK6GkkcL-_pw';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/distancematrix/json';

  /// Calcula el tiempo estimado de llegada desde el bus hasta un destino
  /// Retorna tiempo en minutos, o null si falla
  static Future<int?> getETA({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?origins=${origin.latitude},${origin.longitude}'
        '&destinations=${destination.latitude},${destination.longitude}'
        '&mode=driving'
        '&departure_time=now'
        '&traffic_model=best_guess'
        '&key=$_apiKey',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && 
            data['rows'] != null && 
            data['rows'].isNotEmpty &&
            data['rows'][0]['elements'] != null &&
            data['rows'][0]['elements'].isNotEmpty) {
          
          final element = data['rows'][0]['elements'][0];
          
          if (element['status'] == 'OK' && element['duration_in_traffic'] != null) {
            final durationSeconds = element['duration_in_traffic']['value'];
            return (durationSeconds / 60).round();
          } else if (element['status'] == 'OK' && element['duration'] != null) {
            final durationSeconds = element['duration']['value'];
            return (durationSeconds / 60).round();
          }
        }
      }
    } catch (_) {}

    return null;
  }

  /// Calcula distancia en kilómetros desde el bus hasta un destino
  static Future<double?> getDistance({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?origins=${origin.latitude},${origin.longitude}'
        '&destinations=${destination.latitude},${destination.longitude}'
        '&mode=driving'
        '&key=$_apiKey',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && 
            data['rows'] != null && 
            data['rows'].isNotEmpty &&
            data['rows'][0]['elements'] != null &&
            data['rows'][0]['elements'].isNotEmpty) {
          
          final element = data['rows'][0]['elements'][0];
          
          if (element['status'] == 'OK' && element['distance'] != null) {
            final distanceMeters = element['distance']['value'];
            return distanceMeters / 1000.0;
          }
        }
      }
    } catch (_) {}

    return null;
  }
}

