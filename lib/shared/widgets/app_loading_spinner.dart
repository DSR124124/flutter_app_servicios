import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';

/// Widget de spinner de carga con los colores de NETTALCO
/// Puede usarse como overlay de pantalla completa o como widget individual
class AppLoadingSpinner extends StatelessWidget {
  const AppLoadingSpinner({
    super.key,
    this.size = 50.0,
    this.strokeWidth = 4.0,
    this.message,
  });

  /// Tamaño del spinner
  final double size;

  /// Grosor de la línea del spinner
  final double strokeWidth;

  /// Mensaje opcional a mostrar debajo del spinner
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.blueLight,
            ),
            backgroundColor: AppColors.lightGray,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// Muestra un overlay de carga de pantalla completa
  /// con fondo blanco semi-transparente
  static void showOverlay(
    BuildContext context, {
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white.withOpacity(0.8),
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AppLoadingSpinner(message: message),
          ),
        ),
      ),
    );
  }

  /// Cierra el overlay de carga mostrado con showOverlay
  static void hideOverlay(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

/// Widget de spinner personalizado con colores degradados de NETTALCO
class AppGradientSpinner extends StatefulWidget {
  const AppGradientSpinner({
    super.key,
    this.size = 50.0,
    this.strokeWidth = 4.0,
    this.message,
  });

  final double size;
  final double strokeWidth;
  final String? message;

  @override
  State<AppGradientSpinner> createState() => _AppGradientSpinnerState();

  /// Muestra un overlay de carga con spinner degradado
  static void showOverlay(
    BuildContext context, {
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white.withOpacity(0.8),
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AppGradientSpinner(message: message),
          ),
        ),
      ),
    );
  }

  /// Cierra el overlay de carga
  static void hideOverlay(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

class _AppGradientSpinnerState extends State<AppGradientSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RotationTransition(
          turns: _controller,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _GradientCirclePainter(
              strokeWidth: widget.strokeWidth,
            ),
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Painter personalizado para el spinner con degradado de colores NETTALCO
class _GradientCirclePainter extends CustomPainter {
  _GradientCirclePainter({required this.strokeWidth});

  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = SweepGradient(
      colors: [
        AppColors.blueLight,
        AppColors.mintLight,
        AppColors.navyDark,
        AppColors.blueLight,
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Dibuja un arco de 270 grados
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57, // -90 grados en radianes (empezar desde arriba)
      4.71, // 270 grados en radianes
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget simple de puntos de carga animados
class AppDotsSpinner extends StatefulWidget {
  const AppDotsSpinner({
    super.key,
    this.size = 12.0,
    this.message,
  });

  final double size;
  final String? message;

  @override
  State<AppDotsSpinner> createState() => _AppDotsSpinnerState();
}

class _AppDotsSpinnerState extends State<AppDotsSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final delay = index * 0.2;
                final value = (_controller.value - delay) % 1.0;
                final scale = value < 0.5 ? value * 2 : (1 - value) * 2;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: widget.size * 0.3),
                  child: Transform.scale(
                    scale: 0.5 + scale * 0.5,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: [
                          AppColors.navyDark,
                          AppColors.blueLight,
                          AppColors.mintLight,
                        ][index],
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

