import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/progress_spinner.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/usecases/get_perfil_info_usecase.dart';
import '../bloc/dashboard_provider.dart';
import '../widgets/perfil_info_list.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider(
        getPerfilInfoUseCase: GetPerfilInfoUseCase(
          DashboardRepositoryImpl(
            authRepository: context.read<AuthProvider>().repository,
          ),
        ),
      ),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  String? _lastErrorMessage;
  bool _hasShownWelcome = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasShownWelcome) return;
      _hasShownWelcome = true;
      AppToast.show(
        context,
        message: AppStrings.loginSuccess,
        type: ToastType.success,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final user = authProvider.user;
    final error = dashboardProvider.error;

    if (error != null && error != _lastErrorMessage) {
      _lastErrorMessage = error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppToast.show(context, message: error, type: ToastType.error);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${user?.username ?? ''}',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            Text(
              'Rol asignado: ${user?.rol ?? ''}',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.dashboardCardTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.dashboardCardSubtitle,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: dashboardProvider.isLoading
                          ? null
                          : dashboardProvider.loadPerfil,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: dashboardProvider.isLoading
                  ? const ProgressSpinner(message: AppStrings.loading)
                  : dashboardProvider.error != null
                  ? Center(
                      child: Text(
                        dashboardProvider.error!,
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : dashboardProvider.perfil != null
                  ? PerfilInfoList(perfil: dashboardProvider.perfil!)
                  : const Center(child: Text(AppStrings.noData)),
            ),
          ],
        ),
      ),
    );
  }
}
