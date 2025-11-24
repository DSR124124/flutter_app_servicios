import 'package:flutter/material.dart';
import 'button_colors.dart';

/// Design Tokens del NETTALCO Design System
class DesignTokens {
  // ====== BORDER RADIUS ======

  static const double radiusSm = 4.0; // 0.25rem
  static const double radiusMd = 6.0; // 0.375rem
  static const double radiusLg = 8.0; // 0.5rem
  static const double radiusFull = 50.0; // 50%

  // ====== FONT WEIGHTS ======

  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemibold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // ====== SHADOWS ======

  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      offset: const Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      offset: const Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      offset: const Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      offset: const Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      offset: const Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -2,
    ),
  ];

  // ====== FOCUS RING ======

  static BoxDecoration get focusRing => BoxDecoration(
    border: Border.all(
      color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
      width: 3,
    ),
    borderRadius: BorderRadius.circular(radiusMd),
  );

  // ====== BUTTON SIZES ======

  static EdgeInsets getButtonPadding(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: 11.2,
          vertical: 5.6,
        ); // 0.35rem 0.7rem
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8.8,
        ); // 0.55rem 1rem
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12.8,
        ); // 0.8rem 1.25rem
    }
  }

  static double getButtonFontSize(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 12.8; // 0.8rem
      case ButtonSize.medium:
        return 15.2; // 0.95rem
      case ButtonSize.large:
        return 16.8; // 1.05rem
    }
  }

  static double getIconButtonSize(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 32.0; // 2rem
      case ButtonSize.medium:
        return 36.0; // 2.25rem
      case ButtonSize.large:
        return 44.0; // 2.75rem
    }
  }
}
