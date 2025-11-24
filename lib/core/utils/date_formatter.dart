import 'package:intl/intl.dart';

/// Utilidades para formatear fechas
class DateFormatter {
  DateFormatter._();

  /// Formatea una fecha a formato corto (dd/MM/yyyy)
  static String formatShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formatea una fecha a formato largo (dd de MMMM de yyyy)
  static String formatLong(DateTime date) {
    return DateFormat('dd \'de\' MMMM \'de\' yyyy', 'es').format(date);
  }

  /// Formatea una fecha con hora (dd/MM/yyyy HH:mm)
  static String formatWithTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Formatea una fecha a formato ISO (yyyy-MM-dd)
  static String formatISO(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Formatea una fecha a formato relativo (hace X días, hoy, ayer)
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Hace unos momentos';
        }
        return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
      }
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Hace $weeks semana${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Hace $months mes${months > 1 ? 'es' : ''}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Hace $years año${years > 1 ? 's' : ''}';
    }
  }

  /// Parsea una fecha desde un string ISO
  static DateTime? parseISO(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (_) {
      return null;
    }
  }
}

