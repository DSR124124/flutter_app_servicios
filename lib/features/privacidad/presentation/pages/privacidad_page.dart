import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_loading_spinner.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../bloc/privacidad_provider.dart';
import '../../data/repositories/privacidad_repository_impl.dart';
import '../../domain/usecases/get_version_actual_usecase.dart';

class PrivacidadPage extends StatelessWidget {
  const PrivacidadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PrivacidadProvider(
        getVersionActualUseCase: GetVersionActualUseCase(
          PrivacidadRepositoryImpl(),
        ),
      )..loadVersionActual(),
      child: const _PrivacidadView(),
    );
  }
}

class _PrivacidadView extends StatefulWidget {
  const _PrivacidadView();

  @override
  State<_PrivacidadView> createState() => _PrivacidadViewState();
}

class _PrivacidadViewState extends State<_PrivacidadView> {
  String? _lastErrorMessage;

  @override
  Widget build(BuildContext context) {
    final privacidadProvider = context.watch<PrivacidadProvider>();
    final error = privacidadProvider.error;

    if (error != null && error != _lastErrorMessage) {
      _lastErrorMessage = error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppToast.show(context, message: error, type: ToastType.error);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textoHeader,
        elevation: 0,
        title: const Text(
          AppStrings.privacidadTitle,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: privacidadProvider.isInitialLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppGradientSpinner(size: 50),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.privacidadLoading,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : privacidadProvider.error != null && privacidadProvider.versionActual == null
              ? _buildErrorState(privacidadProvider)
              : privacidadProvider.versionActual != null
                  ? _buildContent(context, privacidadProvider.versionActual!)
                  : _buildEmptyState(),
    );
  }

  Widget _buildErrorState(PrivacidadProvider privacidadProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              privacidadProvider.error!,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: privacidadProvider.loadVersionActual,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text(
                AppStrings.retry,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.privacy_tip_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.noData,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, version) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con versión y fecha
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.privacy_tip,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        version.titulo,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 16),
                // Info badges
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildInfoBadge(
                      icon: Icons.tag,
                      label: '${AppStrings.privacidadVersion} ${version.numeroVersion}',
                      color: AppColors.secondary,
                    ),
                    if (version.fechaVigenciaInicio != null)
                      _buildInfoBadge(
                        icon: Icons.calendar_today,
                        label: '${AppStrings.privacidadVigenciaDesde} ${_formatDate(version.fechaVigenciaInicio)}',
                        color: AppColors.tealDark,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Resumen de cambios si existe
          if (version.resumenCambios != null && version.resumenCambios!.isNotEmpty) ...[
            _buildSectionHeader(
              icon: Icons.change_circle_outlined,
              title: AppStrings.privacidadResumenCambios,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mintLight.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.mintDarker.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.tealDark,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      version.resumenCambios!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // Contenido principal
          _buildSectionHeader(
            icon: Icons.article_outlined,
            title: 'Contenido',
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: Text(
              version.contenido,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

