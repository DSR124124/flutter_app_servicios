import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Utilidades para gradientes de texto según NETTALCO Design System
class TextGradients {
  /// Gradiente primario (Navy a Blue)
  static Shader primaryGradient(Rect bounds) {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.navyDark, AppColors.blueLight],
    ).createShader(bounds);
  }

  /// Gradiente secundario (Blue a Mint)
  static Shader secondaryGradient(Rect bounds) {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.blueLight, AppColors.mintLight],
    ).createShader(bounds);
  }

  /// Gradiente de acento (Mint a Teal)
  static Shader accentGradient(Rect bounds) {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.mintLight, AppColors.tealDark],
    ).createShader(bounds);
  }

  /// Widget de texto con gradiente primario
  static Widget primaryGradientText(String text, {TextStyle? style}) {
    return ShaderMask(
      shaderCallback: (bounds) => primaryGradient(bounds),
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Widget de texto con gradiente secundario
  static Widget secondaryGradientText(String text, {TextStyle? style}) {
    return ShaderMask(
      shaderCallback: (bounds) => secondaryGradient(bounds),
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Widget de texto con gradiente de acento
  static Widget accentGradientText(String text, {TextStyle? style}) {
    return ShaderMask(
      shaderCallback: (bounds) => accentGradient(bounds),
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Widget de texto destacado (highlight)
  static Widget highlightText(String text, {TextStyle? style}) {
    return ShaderMask(
      shaderCallback: (bounds) => secondaryGradient(bounds),
      child: Text(
        text,
        style: (style ?? const TextStyle(fontSize: 18)).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
