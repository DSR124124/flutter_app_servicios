/// Información de tiempo estimado de llegada a un paradero
class StopETA {
  final String stopName;
  final double latitude;
  final double longitude;
  final int? estimatedMinutes;
  final double? distanceKm;

  const StopETA({
    required this.stopName,
    required this.latitude,
    required this.longitude,
    this.estimatedMinutes,
    this.distanceKm,
  });

  String get formattedETA {
    if (estimatedMinutes == null) return 'Calculando...';
    if (estimatedMinutes! < 1) return 'Llegando ahora';
    if (estimatedMinutes! < 60) return '$estimatedMinutes min';
    final hours = estimatedMinutes! ~/ 60;
    final mins = estimatedMinutes! % 60;
    if (mins == 0) return '$hours h';
    return '$hours h $mins min';
  }

  String get formattedDistance {
    if (distanceKm == null) return '';
    if (distanceKm! < 1) return '${(distanceKm! * 1000).round()} m';
    return '${distanceKm!.toStringAsFixed(1)} km';
  }
}

