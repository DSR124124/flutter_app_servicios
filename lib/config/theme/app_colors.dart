import 'package:flutter/material.dart';

/// Paleta de colores NETTALCO Design System
class AppColors {
  // ====== BRANDING COLORS ======
  
  // Navy Colors (Primary)
  static const Color navyDark = Color(0xFF1C224D); // --color-navy-dark
  static const Color navyLighter = Color(0xFF2A3066); // --color-navy-lighter
  static const Color navyDarker = Color(0xFF141A3D); // --color-navy-darker
  
  // Blue Colors (Secondary/Highlight)
  static const Color blueLight = Color(0xFF4A7AFF); // --color-blue-light
  static const Color blueLighter = Color(0xFF6B8FFF); // --color-blue-lighter
  static const Color blueDarker = Color(0xFF2954FF); // --color-blue-darker
  static const Color lightBlue = Color(0xB2B7CAFF); // --color-light-blue (con transparencia)
  
  // Mint Colors (Accent)
  static const Color mintLight = Color(0xFFA2F0A1); // --color-mint-light
  static const Color mintLighter = Color(0xFFB8F5B7); // --color-mint-lighter
  static const Color mintDarker = Color(0xFF7ED47D); // --color-mint-darker
  
  // Teal Colors
  static const Color tealDark = Color(0xFF176973); // --color-teal-dark
  
  // ====== NEUTRAL COLORS ======
  
  static const Color white = Color(0xFFFFFFFF); // --color-white
  static const Color lightGray = Color(0xFFE6E6E6); // --color-light-gray
  static const Color grayMedium = Color(0xFF7A7A7A); // --color-gray-medium
  static const Color grayDark = Color(0xFF4A5568); // --color-gray-dark
  static const Color grayLight = Color(0xFFF7FAFC); // --color-gray-light
  static const Color grayLighter = Color(0xFFEDF2F7); // --color-gray-lighter
  
  // ====== STATE COLORS ======
  
  static const Color success = Color(0xFFA2F0A1); // --color-success (mint-light)
  static const Color info = Color(0xFF4A7AFF); // --color-info (blue-light)
  static const Color warning = Color(0xFFFFA726); // --color-warning
  static const Color danger = Color(0xFFEF5350); // --color-danger
  
  // ====== LAYOUT COLORS ======
  
  static const Color layoutHeaderBg = Color(0xFF1C224D); // navyDark
  static const Color layoutSidebarBg = Color(0xFFF5F8FC); // --layout-sidebar-bg
  static const Color layoutFooterBg = Color(0xFF151515); // --layout-footer-bg
  static const Color layoutMainBg = Color(0xFFFFFFFF); // white
  
  // ====== TEXT COLORS ======
  
  static const Color textoContent = Color(0xFF000000); // --texto-content-color
  static const Color textoHeader = Color(0xFFFFFFFF); // --texto-header-color
  static const Color textoFooter = Color(0xFFFFFFFF); // --texto-footer-color
  static const Color textoSidebar = Color(0xFFFFFFFF); // --texto-sidebar-color
  static const Color primaryContent = Color(0xFFFFFFFF); // --primary-content-color
  
  // ====== ALIASES PARA COMPATIBILIDAD ======
  
  // Primary (usando Navy como primary)
  static const Color primary = navyDark;
  static const Color primaryDark = navyDarker;
  static const Color primaryLight = navyLighter;
  
  // Secondary (usando Blue como secondary)
  static const Color secondary = blueLight;
  static const Color secondaryDark = blueDarker;
  static const Color secondaryLight = blueLighter;
  
  // Background Colors
  static const Color background = grayLight;
  static const Color surface = white;
  
  // Text Colors
  static const Color textPrimary = textoContent;
  static const Color textSecondary = grayMedium;
  static const Color textHint = grayLighter;
  
  // Error (usando danger)
  static const Color error = danger;
  
  // Border
  static const Color border = lightGray;
  
  // Disable
  static const Color disabled = grayMedium;
}

