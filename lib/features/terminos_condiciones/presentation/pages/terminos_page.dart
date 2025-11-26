import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_loading_spinner.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../bloc/terminos_provider.dart';
import '../../data/repositories/terminos_repository_impl.dart';
import '../../domain/usecases/get_version_actual_usecase.dart';

class TerminosPage extends StatelessWidget {
  const TerminosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TerminosProvider(
        getVersionActualUseCase: GetVersionActualUseCase(
          TerminosRepositoryImpl(),
        ),
      )..loadVersionActual(),
      child: const _TerminosView(),
    );
  }
}

class _TerminosView extends StatefulWidget {
  const _TerminosView();

  @override
  State<_TerminosView> createState() => _TerminosViewState();
}

class _TerminosViewState extends State<_TerminosView> {
  String? _lastErrorMessage;

  @override
  Widget build(BuildContext context) {
    final terminosProvider = context.watch<TerminosProvider>();
    final error = terminosProvider.error;

    if (error != null && error != _lastErrorMessage) {
      _lastErrorMessage = error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppToast.show(context, message: error, type: ToastType.error);
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(AppStrings.terminosTitle),
        foregroundColor: AppColors.textPrimary,
      ),
      body: Container(
        color: Colors.white,
        child: terminosProvider.isInitialLoading
          ? const Center(
              child: AppLoadingSpinner(
                message: AppStrings.terminosLoading,
              ),
            )
          : terminosProvider.error != null && terminosProvider.versionActual == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        terminosProvider.error!,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: terminosProvider.loadVersionActual,
                        icon: const Icon(Icons.refresh),
                        label: const Text(AppStrings.retry),
                      ),
                    ],
                  ),
                )
              : terminosProvider.versionActual != null
                  ? _buildContent(context, terminosProvider.versionActual!)
                  : const Center(child: Text(AppStrings.noData)),
      ),
    );
  }

  Widget _buildContent(BuildContext context, version) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con versión y fecha
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          version.titulo,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.tag,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${AppStrings.terminosVersion} ${version.numeroVersion}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  if (version.fechaVigenciaInicio != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${AppStrings.terminosVigenciaDesde} ${_formatDate(version.fechaVigenciaInicio)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Resumen de cambios si existe
          if (version.resumenCambios != null && version.resumenCambios!.isNotEmpty) ...[
            Text(
              AppStrings.terminosResumenCambios,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              color: AppColors.primary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  version.resumenCambios!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Contenido
          Text(
            'Contenido',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                version.contenido,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

