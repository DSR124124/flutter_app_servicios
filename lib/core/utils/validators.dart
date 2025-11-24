/// Utilidades para validación de formularios
class Validators {
  Validators._();

  /// Valida que el campo no esté vacío
  static String? required(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? 'Este campo es obligatorio';
    }
    return null;
  }

  /// Valida un email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingrese un email válido';
    }

    return null;
  }

  /// Valida que la contraseña tenga al menos 6 caracteres
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }

    if (value.length < minLength) {
      return 'La contraseña debe tener al menos $minLength caracteres';
    }

    return null;
  }

  /// Valida que dos contraseñas coincidan
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }

    if (value != password) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  /// Valida un número de teléfono
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    final phoneRegex = RegExp(r'^[0-9]{8,10}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Ingrese un número de teléfono válido';
    }

    return null;
  }

  /// Valida que el valor tenga una longitud mínima
  static String? minLength(String? value, int minLength, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    if (value.length < minLength) {
      return message ?? 'Debe tener al menos $minLength caracteres';
    }

    return null;
  }

  /// Valida que el valor tenga una longitud máxima
  static String? maxLength(String? value, int maxLength, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    if (value.length > maxLength) {
      return message ?? 'No debe exceder $maxLength caracteres';
    }

    return null;
  }

  /// Valida un número
  static String? number(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    if (double.tryParse(value) == null) {
      return 'Ingrese un número válido';
    }

    return null;
  }

  /// Valida que el número sea positivo
  static String? positiveNumber(String? value) {
    final numberError = number(value);
    if (numberError != null) return numberError;

    if (double.parse(value!) <= 0) {
      return 'El número debe ser mayor a cero';
    }

    return null;
  }
}

