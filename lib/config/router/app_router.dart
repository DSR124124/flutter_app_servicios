import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/servicios/presentation/pages/servicios_page.dart';

/// Configuración de rutas de la aplicación usando go_router
class AppRouter {
  AppRouter._();

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoginRoute = state.matchedLocation == '/login';

        // Si no está autenticado y no está en login, redirigir a login
        if (!isAuthenticated && !isLoginRoute) {
          return '/login';
        }

        // Si está autenticado y está en login, redirigir a servicios
        if (isAuthenticated && isLoginRoute) {
          return '/servicios';
        }

        return null; // No redirigir
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/servicios',
          name: 'servicios',
          builder: (context, state) => const ServiciosPage(),
        ),
        GoRoute(
          path: '/',
          redirect: (_, __) => '/servicios',
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Página no encontrada',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.matchedLocation,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/servicios'),
                child: const Text('Ir a Servicios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Router estático para compatibilidad (se inicializará en main)
  static GoRouter? _router;

  static GoRouter get router {
    if (_router == null) {
      throw StateError(
        'Router no inicializado. Use AppRouter.createRouter() primero.',
      );
    }
    return _router!;
  }

  static void initialize(AuthProvider authProvider) {
    _router = createRouter(authProvider);
  }
}
