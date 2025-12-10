import 'ruta_model.dart';

class RutaCompletaModel {
  final RutaModel ruta;
  final List<ViajeActivoModel> viajesActivos;
  final List<HorarioModel> horarios;

  RutaCompletaModel({
    required this.ruta,
    required this.viajesActivos,
    required this.horarios,
  });

  factory RutaCompletaModel.fromJson(Map<String, dynamic> json) {
    return RutaCompletaModel(
      ruta: RutaModel.fromJson(json['ruta'] as Map<String, dynamic>),
      viajesActivos: (json['viajesActivos'] as List<dynamic>? ?? [])
          .map((v) => ViajeActivoModel.fromJson(v as Map<String, dynamic>))
          .toList(),
      horarios: (json['horarios'] as List<dynamic>? ?? [])
          .map((h) => HorarioModel.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ViajeActivoModel {
  final int idViaje;
  final int idRuta;
  final String busPlate;
  final String? busModel;
  final String driverName;
  final String estado;
  final String? fechaInicioProgramada;
  final String? fechaFinProgramada;

  ViajeActivoModel({
    required this.idViaje,
    required this.idRuta,
    required this.busPlate,
    this.busModel,
    required this.driverName,
    required this.estado,
    this.fechaInicioProgramada,
    this.fechaFinProgramada,
  });

  factory ViajeActivoModel.fromJson(Map<String, dynamic> json) {
    return ViajeActivoModel(
      idViaje: (json['idViaje'] as num?)?.toInt() ?? 0,
      idRuta: (json['idRuta'] as num?)?.toInt() ?? 0,
      busPlate: json['busPlate'] as String? ?? '',
      busModel: json['busModel'] as String?,
      driverName: json['driverName'] as String? ?? '',
      estado: json['estado'] as String? ?? '',
      fechaInicioProgramada: json['fechaInicioProgramada'] as String?,
      fechaFinProgramada: json['fechaFinProgramada'] as String?,
    );
  }
}

class HorarioModel {
  final String horaInicio;
  final String horaFin;
  final String frecuencia;
  final String diasSemana;

  HorarioModel({
    required this.horaInicio,
    required this.horaFin,
    required this.frecuencia,
    required this.diasSemana,
  });

  factory HorarioModel.fromJson(Map<String, dynamic> json) {
    return HorarioModel(
      horaInicio: json['horaInicio'] as String? ?? '',
      horaFin: json['horaFin'] as String? ?? '',
      frecuencia: json['frecuencia'] as String? ?? '',
      diasSemana: json['diasSemana'] as String? ?? '',
    );
  }
}
