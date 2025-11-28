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
    const radius = size / 2.3;

    // Sombra
    canvas.drawCircle(
      Offset(center.dx, center.dy + 2),
      radius,
      Paint()
        ..color = Colors.black.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Fondo blanco
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);

    // Borde azul
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF2196F3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Emoji del bus
    final textPainter = TextPainter(textDirection: TextDirection.ltr)
      ..text = const TextSpan(text: '🚌', style: TextStyle(fontSize: 58))
      ..layout();
    
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2 - 2,
      ),
    );

    final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
}
