/// Strings constantes de la aplicación
class AppStrings {
  // ===== App Info =====
  static const String appName = 'Nettalco Servicios';
  static const String appDescription =
      'Gestión de servicios con arquitectura dual backend';

  // ===== Common =====
  static const String loading = 'Cargando...';
  static const String error = 'Error';
  static const String success = 'Éxito';
  static const String cancel = 'Cancelar';
  static const String confirm = 'Confirmar';
  static const String save = 'Guardar';
  static const String delete = 'Eliminar';
  static const String edit = 'Editar';
  static const String retry = 'Reintentar';
  static const String noData = 'Aún no hay datos disponibles';

  // ===== Auth =====
  static const String loginTitle = 'Bienvenido a Nettalco';
  static const String loginSubtitle =
      'Inicia sesión para gestionar los servicios';
  static const String loginUserHint = 'Usuario o correo';
  static const String loginPasswordHint = 'Contraseña';
  static const String loginButton = 'Ingresar';
  static const String loginRequiredUser =
      'Ingresa tu usuario o correo'; // validation
  static const String loginRequiredPassword = 'Ingresa tu contraseña';
  static const String sessionExpired = 'Tu sesión ha expirado. Inicia sesión.';
  static const String invalidCredentials =
      'Credenciales inválidas o usuario no autorizado';
  static const String loginSuccess = 'Inicio de sesión exitoso';

  // ===== Dashboard =====
  static const String dashboardTitle = 'Panel de Servicios';
  static const String dashboardCardTitle = 'Mi Información';
  static const String dashboardCardSubtitle =
      'Tu información personal y de cuenta';
  
  // ===== Menu =====
  static const String menuMiPerfil = 'Mi Perfil';
  static const String menuServicios = 'Servicios';
  static const String menuTerminos = 'Términos y Condiciones';
  static const String menuPrivacidad = 'Política de Privacidad';
  static const String menuChatbot = 'Chatbot';
  static const String menuCerrarSesion = 'Cerrar Sesión';
  
  // ===== Servicios =====
  static const String serviciosTitle = 'Mis Servicios';
  static const String serviciosEmpty = 'Aún no tienes servicios registrados';
  
  // ===== Términos y Condiciones =====
  static const String terminosTitle = 'Términos y Condiciones';
  static const String terminosLoading = 'Cargando términos y condiciones...';
  static const String terminosError = 'Error al cargar los términos y condiciones';
  static const String terminosVersion = 'Versión';
  static const String terminosVigenciaDesde = 'Vigente desde';
  static const String terminosResumenCambios = 'Resumen de cambios';

  // ===== Política de Privacidad =====
  static const String privacidadTitle = 'Política de Privacidad';
  static const String privacidadLoading = 'Cargando política de privacidad...';
  static const String privacidadError = 'Error al cargar la política de privacidad';
  static const String privacidadVersion = 'Versión';
  static const String privacidadVigenciaDesde = 'Vigente desde';
  static const String privacidadResumenCambios = 'Resumen de cambios';

  // ===== Chatbot =====
  static const String chatbotTitle = 'Chatbot';
  static const String chatbotLoading = 'Cargando chatbot...';
  static const String chatbotError = 'Error al cargar el chatbot';

  // ===== Errors =====
  static const String networkError = 'Error de conexión';
  static const String serverError = 'Error del servidor';
  static const String unauthorizedError =
      'Sesión inválida o sin autorización. Inicia sesión nuevamente.';
  static const String forbiddenError =
      'No tienes permisos para acceder a este recurso.';
  static const String timeoutError =
      'El servidor tardó demasiado en responder.';
  static const String unknownError = 'Ocurrió un error desconocido';
}
