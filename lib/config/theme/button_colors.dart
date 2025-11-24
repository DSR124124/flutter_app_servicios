import 'package:flutter/material.dart';

/// Colores de botones según NETTALCO Design System
class ButtonColors {
  // ====== VERSION 1 COLORS ======

  // Primary
  static const Color primary = Color(0xFF082853);
  static const Color primaryHover = Color(0xFF22436F);
  static const Color primaryActive = Color(0xFF2B5DA1);
  static const Color primaryDisabled = Color(0xFFD7E3FB);

  // Secondary
  static const Color secondary = Color(0xFF3F8CF9);
  static const Color secondaryHover = Color(0xFF5A9FFC);
  static const Color secondaryActive = Color(0xFF5398F8);
  static const Color secondaryDisabled = Color(0xFFCAD8F1);

  // Success
  static const Color success = Color(0xFF2BA5CD);
  static const Color successHover = Color(0xFF45B1CE);
  static const Color successActive = Color(0xFF3CAAC8);
  static const Color successDisabled = Color(0xFFD6E5FA);

  // Export
  static const Color export = Color(0xFF09718A);
  static const Color exportHover = Color(0xFF258FA6);
  static const Color exportActive = Color(0xFF1A859D);
  static const Color exportDisabled = Color(0xFF8CC3D7);

  // Warning
  static const Color warning = Color(0xFFD57952);
  static const Color warningHover = Color(0xFFD78158);
  static const Color warningActive = Color(0xFFDE956A);
  static const Color warningDisabled = Color(0xFFE4DBE7);

  // Danger
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerHover = Color(0xFFEF4444);
  static const Color dangerActive = Color(0xFFB91C1C);
  static const Color dangerDisabled = Color(0xFFFECACA);

  // Info
  static const Color info = Color(0xFF66A6FB);
  static const Color infoHover = Color(0xFF7CB2FA);
  static const Color infoActive = Color(0xFFB4D3FD);
  static const Color infoDisabled = Color(0xFFABC9F9);

  // Text Colors
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF082853);

  // ====== VERSION 2 COLORS ======

  // Primary v2
  static const Color v2Primary = Color(0xFFEDF4FF);
  static const Color v2PrimaryHover = Color(0xFFEEF4FF);
  static const Color v2PrimaryActive = Color(0xFF336DD9);
  static const Color v2PrimaryDisabled = Color(0xFF0A1D49);

  // Secondary v2
  static const Color v2Secondary = Color(0xFF3A72E0);
  static const Color v2SecondaryHover = Color(0xFF2B5FBC);
  static const Color v2SecondaryActive = Color(0xFF1F498E);
  static const Color v2SecondaryDisabled = Color(0xFF0C3D5C);

  // Success v2
  static const Color v2Success = Color(0xFF6ECBCD);
  static const Color v2SuccessHover = Color(0xFF19819D);
  static const Color v2SuccessActive = Color(0xFF0C566F);
  static const Color v2SuccessDisabled = Color(0xFF0C3D5C);

  // Warning v2
  static const Color v2Warning = Color(0xFFF4B33C);
  static const Color v2WarningHover = Color(0xFFF2A61E);
  static const Color v2WarningActive = Color(0xFFCA8825);
  static const Color v2WarningDisabled = Color(0xFF9D6A2D);

  // Info v2
  static const Color v2Info = Color(0xFF69A7ED);
  static const Color v2InfoHover = Color(0xFF5389DB);
  static const Color v2InfoActive = Color(0xFF4775BF);
  static const Color v2InfoDisabled = Color(0xFF40609B);

  // Text helpers v2
  static const Color v2TextDark = Color(0xFF0A1D49);
  static const Color v2TextLight = Color(0xFFFFFFFF);

  // ====== HELPER METHODS ======

  /// Obtiene el color de fondo según la severidad y versión
  static Color getBackgroundColor(
    ButtonSeverity severity, {
    bool isV2 = false,
  }) {
    if (isV2) {
      switch (severity) {
        case ButtonSeverity.primary:
          return v2Primary;
        case ButtonSeverity.secondary:
          return v2Secondary;
        case ButtonSeverity.success:
          return v2Success;
        case ButtonSeverity.export:
          return v2Success; // Export usa success en v2
        case ButtonSeverity.warning:
          return v2Warning;
        case ButtonSeverity.danger:
          return danger; // Danger no tiene v2 específico
        case ButtonSeverity.info:
          return v2Info;
      }
    } else {
      switch (severity) {
        case ButtonSeverity.primary:
          return primary;
        case ButtonSeverity.secondary:
          return secondary;
        case ButtonSeverity.success:
          return success;
        case ButtonSeverity.export:
          return export;
        case ButtonSeverity.warning:
          return warning;
        case ButtonSeverity.danger:
          return danger;
        case ButtonSeverity.info:
          return info;
      }
    }
  }

  /// Obtiene el color de hover según la severidad y versión
  static Color getHoverColor(ButtonSeverity severity, {bool isV2 = false}) {
    if (isV2) {
      switch (severity) {
        case ButtonSeverity.primary:
          return v2PrimaryHover;
        case ButtonSeverity.secondary:
          return v2SecondaryHover;
        case ButtonSeverity.success:
          return v2SuccessHover;
        case ButtonSeverity.export:
          return v2SuccessHover;
        case ButtonSeverity.warning:
          return v2WarningHover;
        case ButtonSeverity.danger:
          return dangerHover;
        case ButtonSeverity.info:
          return v2InfoHover;
      }
    } else {
      switch (severity) {
        case ButtonSeverity.primary:
          return primaryHover;
        case ButtonSeverity.secondary:
          return secondaryHover;
        case ButtonSeverity.success:
          return successHover;
        case ButtonSeverity.export:
          return exportHover;
        case ButtonSeverity.warning:
          return warningHover;
        case ButtonSeverity.danger:
          return dangerHover;
        case ButtonSeverity.info:
          return infoHover;
      }
    }
  }

  /// Obtiene el color de texto según la severidad y versión
  static Color getTextColor(ButtonSeverity severity, {bool isV2 = false}) {
    if (isV2) {
      switch (severity) {
        case ButtonSeverity.primary:
          return v2TextDark;
        case ButtonSeverity.secondary:
        case ButtonSeverity.success:
        case ButtonSeverity.export:
        case ButtonSeverity.warning:
        case ButtonSeverity.danger:
        case ButtonSeverity.info:
          return v2TextLight;
      }
    } else {
      switch (severity) {
        case ButtonSeverity.primary:
        case ButtonSeverity.secondary:
        case ButtonSeverity.export:
        case ButtonSeverity.danger:
        case ButtonSeverity.info:
          return textLight;
        case ButtonSeverity.success:
          return textDark;
        case ButtonSeverity.warning:
          return const Color(0xFF1A1A1A);
      }
    }
  }
}

/// Severidad del botón
enum ButtonSeverity {
  primary,
  secondary,
  success,
  export,
  warning,
  danger,
  info,
}

/// Variante del botón
enum ButtonVariant { filled, outlined, text, ghost }

/// Tamaño del botón
enum ButtonSize { small, medium, large }
