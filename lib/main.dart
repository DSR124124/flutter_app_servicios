import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';

void main() {
  runApp(const NettalcoApp());
}

class NettalcoApp extends StatelessWidget {
  const NettalcoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Nettalco Servicios',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading && authProvider.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: authProvider.isAuthenticated
          ? const DashboardPage()
          : const LoginPage(),
    );
  }
}
