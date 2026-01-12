import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_provider.dart';

Future<void> _requestLocationPermission() async {
  // Verificar permisos de ubicación
  LocationPermission permission = await Geolocator.checkPermission();
  
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      // El usuario denegó los permisos, pero continuamos con la app
      // Los permisos se pueden solicitar más tarde cuando se necesiten
      return;
    }
  }
  
  // Verificar que el servicio de ubicación esté habilitado
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // El servicio de ubicación está deshabilitado
    // Se puede mostrar un mensaje al usuario más tarde
    return;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Solicitar permisos de ubicación al inicio
  await _requestLocationPermission();
  
  runApp(const NettalcoApp());
}

class NettalcoApp extends StatelessWidget {
  const NettalcoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProvider();
    AppRouter.initialize(authProvider);

    return ChangeNotifierProvider.value(
      value: authProvider,
      child: MaterialApp.router(
        title: 'Nettalco',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
