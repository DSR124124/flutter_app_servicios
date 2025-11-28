import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapIconHelper {
  MapIconHelper._();

  static Future<BitmapDescriptor> createBusIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 140.0; // Tamaño aumentado para más visibilidad
    const center = Offset(size / 2, size / 2);

    // Sombra 3D más pronunciada y llamativa
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 10),
        width: size * 0.75,
        height: size * 0.45,
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Halo brillante alrededor del bus (efecto llamativo)
    canvas.drawCircle(
      center,
      size * 0.5,
      Paint()
        ..color = const Color(0xFF4A7AFF).withOpacity(0.2)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Cuerpo del bus 3D (perspectiva isométrica) - más grande y llamativo
    final busWidth = size * 0.7;
    final busHeight = size * 0.55;
    final busTop = center.dy - busHeight * 0.3;
    final busLeft = center.dx - busWidth / 2;

    // Parte superior del bus (techo en perspectiva) con gradiente
    final topPath = Path()
      ..moveTo(busLeft, busTop)
      ..lineTo(busLeft + busWidth * 0.3, busTop - busHeight * 0.18)
      ..lineTo(busLeft + busWidth * 0.7, busTop - busHeight * 0.18)
      ..lineTo(busLeft + busWidth, busTop)
      ..close();
    
    // Gradiente para el techo (más llamativo)
    final topGradient = ui.Gradient.linear(
      Offset(busLeft, busTop - busHeight * 0.18),
      Offset(busLeft, busTop),
      [
        const Color(0xFF6B8FFF),
        const Color(0xFF4A7AFF),
      ],
    );
    
    canvas.drawPath(
      topPath,
      Paint()
        ..shader = topGradient
        ..style = PaintingStyle.fill,
    );

    // Borde brillante del techo
    canvas.drawPath(
      topPath,
      Paint()
        ..color = const Color(0xFF2954FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Cuerpo principal del bus (lado frontal) con gradiente
    final frontRect = Rect.fromLTWH(
      busLeft,
      busTop,
      busWidth,
      busHeight,
    );
    
    // Gradiente vertical para el cuerpo
    final bodyGradient = ui.Gradient.linear(
      Offset(busLeft, busTop),
      Offset(busLeft, busTop + busHeight),
      [
        const Color(0xFF4A7AFF),
        const Color(0xFF2954FF),
      ],
    );
    
    canvas.drawRect(
      frontRect,
      Paint()
        ..shader = bodyGradient
        ..style = PaintingStyle.fill,
    );

    // Borde brillante del cuerpo con efecto de resaltado
    canvas.drawRect(
      frontRect,
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRect(
      frontRect,
      Paint()
        ..color = const Color(0xFF1C224D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Ventanas del bus (perspectiva 3D)
    final windowWidth = busWidth * 0.25;
    final windowHeight = busHeight * 0.35;
    final windowSpacing = busWidth * 0.15;
    
    // Ventana izquierda
    final leftWindowPath = Path()
      ..moveTo(busLeft + windowSpacing, busTop + busHeight * 0.15)
      ..lineTo(busLeft + windowSpacing + windowWidth * 0.3, busTop + busHeight * 0.05)
      ..lineTo(busLeft + windowSpacing + windowWidth * 0.3, busTop + busHeight * 0.05 + windowHeight)
      ..lineTo(busLeft + windowSpacing, busTop + busHeight * 0.15 + windowHeight)
      ..close();
    
    canvas.drawPath(
      leftWindowPath,
      Paint()
        ..color = const Color(0xFF6B8FFF).withOpacity(0.6)
        ..style = PaintingStyle.fill,
    );

    // Ventana derecha
    final rightWindowPath = Path()
      ..moveTo(busLeft + windowSpacing * 2 + windowWidth, busTop + busHeight * 0.15)
      ..lineTo(busLeft + windowSpacing * 2 + windowWidth + windowWidth * 0.3, busTop + busHeight * 0.05)
      ..lineTo(busLeft + windowSpacing * 2 + windowWidth + windowWidth * 0.3, busTop + busHeight * 0.05 + windowHeight)
      ..lineTo(busLeft + windowSpacing * 2 + windowWidth, busTop + busHeight * 0.15 + windowHeight)
      ..close();
    
    canvas.drawPath(
      rightWindowPath,
      Paint()
        ..color = const Color(0xFF6B8FFF).withOpacity(0.6)
        ..style = PaintingStyle.fill,
    );

    // Bordes de ventanas
    canvas.drawPath(
      leftWindowPath,
      Paint()
        ..color = const Color(0xFF2954FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    
    canvas.drawPath(
      rightWindowPath,
      Paint()
        ..color = const Color(0xFF2954FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Ruedas (círculos en perspectiva)
    final wheelRadius = size * 0.08;
    final wheelY = busTop + busHeight + wheelRadius * 0.5;
    
    // Rueda izquierda
    canvas.drawCircle(
      Offset(busLeft + busWidth * 0.25, wheelY),
      wheelRadius,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(busLeft + busWidth * 0.25, wheelY),
      wheelRadius * 0.6,
      Paint()
        ..color = Colors.grey[300]!
        ..style = PaintingStyle.fill,
    );

    // Rueda derecha
    canvas.drawCircle(
      Offset(busLeft + busWidth * 0.75, wheelY),
      wheelRadius,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(busLeft + busWidth * 0.75, wheelY),
      wheelRadius * 0.6,
      Paint()
        ..color = Colors.grey[300]!
        ..style = PaintingStyle.fill,
    );

    // Líneas decorativas horizontales (más llamativas)
    // Línea superior brillante
    canvas.drawLine(
      Offset(busLeft + busWidth * 0.1, busTop + busHeight * 0.25),
      Offset(busLeft + busWidth * 0.9, busTop + busHeight * 0.25),
      Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..strokeWidth = 2.5,
    );
    
    // Línea media
    canvas.drawLine(
      Offset(busLeft, busTop + busHeight * 0.6),
      Offset(busLeft + busWidth, busTop + busHeight * 0.6),
      Paint()
        ..color = const Color(0xFF2954FF)
        ..strokeWidth = 3,
    );
    
    // Línea inferior
    canvas.drawLine(
      Offset(busLeft + busWidth * 0.1, busTop + busHeight * 0.85),
      Offset(busLeft + busWidth * 0.9, busTop + busHeight * 0.85),
      Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..strokeWidth = 2,
    );

    // Efecto de brillo/resplandor en la parte superior
    canvas.drawPath(
      topPath,
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Punto de dirección (flecha indicadora en la parte frontal)
    final arrowPath = Path()
      ..moveTo(busLeft + busWidth * 0.5, busTop - busHeight * 0.1)
      ..lineTo(busLeft + busWidth * 0.4, busTop + busHeight * 0.05)
      ..lineTo(busLeft + busWidth * 0.6, busTop + busHeight * 0.05)
      ..close();
    
    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
}
