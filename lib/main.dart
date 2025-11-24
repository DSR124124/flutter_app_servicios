import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        title: 'Nettalco Servicios',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
