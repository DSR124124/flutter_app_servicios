import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

/// Servicio para obtener rutas usando Google Directions API
class GoogleDirectionsService {
  static const String _apiKey = 'AIzaSyCnJC_qbY41ZsXjgDLhTmcSK6GkkcL-_pw';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';

  /// Obtiene ruta optimizada pasando por todos los waypoints en orden
  static Future<List<LatLng>> getOptimizedRoute(List<LatLng> waypoints) async {
    if (waypoints.isEmpty) return [];
    if (waypoints.length == 1) return waypoints;
    if (waypoints.length == 2) return await _getRouteSegment(waypoints.first, waypoints.last);

    try {
      final allRoutePoints = <LatLng>[];
      
      for (int i = 0; i < waypoints.length - 1; i++) {
        final segmentPoints = await _getRouteSegment(waypoints[i], waypoints[i + 1]);
        
        if (i == 0) {
          allRoutePoints.addAll(segmentPoints);
        } else {
          allRoutePoints.addAll(segmentPoints.skip(1));
        }
      }
      
      return allRoutePoints;
    } catch (e) {
      return waypoints;
    }
  }

  static Future<List<LatLng>> _getRouteSegment(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?origin=${start.latitude},${start.longitude}'
        '&destination=${end.latitude},${end.longitude}'
        '&mode=driving'
        '&language=es'
        '&key=$_apiKey',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && 
            data['routes'] != null && 
            data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final polyline = route['overview_polyline']['points'];
          return _decodePolyline(polyline);
        }
      }
    } catch (_) {}
    
    return [start, end];
  }

  static List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
}

