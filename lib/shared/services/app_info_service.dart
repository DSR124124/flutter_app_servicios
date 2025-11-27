import 'package:package_info_plus/package_info_plus.dart';

/// Servicio centralizado para obtener información de la app instalada.
class AppInfoService {
  AppInfoService._internal();

  static final AppInfoService _instance = AppInfoService._internal();

  factory AppInfoService() => _instance;

  PackageInfo? _cachedInfo;

  /// Obtiene la versión actual instalada (formato X.Y.Z).
  Future<String> getCurrentVersion() async {
    final info = await _ensurePackageInfo();
    return info.version;
  }

  /// Obtiene el build number actual (si se requiere).
  Future<String> getBuildNumber() async {
    final info = await _ensurePackageInfo();
    return info.buildNumber;
  }

  Future<PackageInfo> _ensurePackageInfo() async {
    _cachedInfo ??= await PackageInfo.fromPlatform();
    return _cachedInfo!;
  }

  /// Limpia el cache (útil después de actualizar la app)
  void clearCache() {
    _cachedInfo = null;
  }
}

