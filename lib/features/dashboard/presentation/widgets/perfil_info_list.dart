import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../domain/entities/perfil_info.dart';

class PerfilInfoList extends StatelessWidget {
  const PerfilInfoList({super.key, required this.perfil});

  final PerfilInfo perfil;

  @override
  Widget build(BuildContext context) {
    final data = <String, dynamic>{
      'ID Usuario': perfil.idUsuario,
      'Usuario': perfil.username,
      'Rol': perfil.rol,
      'Mensaje': perfil.mensaje,
    };

    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final key = data.keys.elementAt(index);
        final value = data[key];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                key,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text('$value', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        );
      },
    );
  }
}
