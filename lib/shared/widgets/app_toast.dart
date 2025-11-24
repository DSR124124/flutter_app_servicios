import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';

enum ToastType { success, info, warning, error }

class AppToast {
  AppToast._();

  static final Map<ToastType, Color> _backgroundColors = {
    ToastType.success: AppColors.success,
    ToastType.info: AppColors.blueLight,
    ToastType.warning: AppColors.warning,
    ToastType.error: AppColors.error,
  };

  static final Map<ToastType, IconData> _icons = {
    ToastType.success: Icons.check_circle_outline,
    ToastType.info: Icons.info_outline,
    ToastType.warning: Icons.warning_amber_rounded,
    ToastType.error: Icons.error_outline,
  };

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _backgroundColors[type],
        duration: duration,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: 16,
          right: 16,
        ),
        content: Row(
          children: [
            Icon(_icons[type], color: AppColors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
