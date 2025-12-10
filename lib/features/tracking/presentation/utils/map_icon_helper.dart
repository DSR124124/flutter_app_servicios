import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapIconHelper {
  MapIconHelper._();

  static Future<BitmapDescriptor> createBusIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 120.0;
    const center = Offset(size / 2, size / 2);

    // Sombra 3D suave
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 8),
        width: size * 0.7,
        height: size * 0.4,
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Cuerpo del bus 3D optimizado
    final busWidth = size * 0.65;
    final busHeight = size * 0.5;
    final busTop = center.dy - busHeight * 0.35;
    final busLeft = center.dx - busWidth / 2;

    // Techo 3D con perspectiva
    final topPath = Path()
      ..moveTo(busLeft, busTop)
      ..lineTo(busLeft + busWidth * 0.25, busTop - busHeight * 0.15)
      ..lineTo(busLeft + busWidth * 0.75, busTop - busHeight * 0.15)
      ..lineTo(busLeft + busWidth, busTop)
      ..close();
    
    final topGradient = ui.Gradient.linear(
      Offset(busLeft, busTop - busHeight * 0.15),
      Offset(busLeft, busTop),
      [const Color(0xFF5B7FFF), const Color(0xFF4169FF)],
    );
    
    canvas.drawPath(topPath, Paint()..shader = topGradient);
    canvas.drawPath(
      topPath,
      Paint()
        ..color = const Color(0xFF2954FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Cuerpo principal con gradiente
    final frontRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(busLeft, busTop, busWidth, busHeight),
      bottomLeft: const Radius.circular(4),
      bottomRight: const Radius.circular(4),
    );
    
    final bodyGradient = ui.Gradient.linear(
      Offset(busLeft, busTop),
      Offset(busLeft, busTop + busHeight),
      [const Color(0xFF4169FF), const Color(0xFF2954FF)],
    );
    
    canvas.drawRRect(frontRect, Paint()..shader = bodyGradient);
    
    // Borde con efecto de brillo
    canvas.drawRRect(
      frontRect,
      Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawRRect(
      frontRect,
      Paint()
        ..color = const Color(0xFF1C224D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Ventanas optimizadas
    final windowWidth = busWidth * 0.22;
    final windowHeight = busHeight * 0.32;
    final windowY = busTop + busHeight * 0.2;
    
    // Ventana izquierda
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(busLeft + busWidth * 0.15, windowY, windowWidth, windowHeight),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF6B8FFF).withOpacity(0.5),
    );
    
    // Ventana derecha
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(busLeft + busWidth * 0.63, windowY, windowWidth, windowHeight),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF6B8FFF).withOpacity(0.5),
    );

    // Ruedas optimizadas
    final wheelRadius = size * 0.075;
    final wheelY = busTop + busHeight + wheelRadius * 0.4;
    
    void drawWheel(Offset position) {
      canvas.drawCircle(position, wheelRadius, Paint()..color = Colors.black87);
      canvas.drawCircle(position, wheelRadius * 0.55, Paint()..color = Colors.grey[350]!);
    }
    
    drawWheel(Offset(busLeft + busWidth * 0.25, wheelY));
    drawWheel(Offset(busLeft + busWidth * 0.75, wheelY));

    // Línea decorativa central
    canvas.drawLine(
      Offset(busLeft, busTop + busHeight * 0.6),
      Offset(busLeft + busWidth, busTop + busHeight * 0.6),
      Paint()
        ..color = const Color(0xFF2954FF)
        ..strokeWidth = 2.5,
    );
    
    // Indicador de dirección (flecha frontal)
    final arrowPath = Path()
      ..moveTo(busLeft + busWidth * 0.5, busTop - busHeight * 0.08)
      ..lineTo(busLeft + busWidth * 0.42, busTop + busHeight * 0.02)
      ..lineTo(busLeft + busWidth * 0.58, busTop + busHeight * 0.02)
      ..close();
    
    canvas.drawPath(arrowPath, Paint()..color = Colors.white);

    final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
}
