import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';

/// Botón de paro de emergencia con confirmación por diálogo.
/// Escribe a `tabla_estado_robot.paro_emergencia` en Supabase.
class EmergencyButtonWidget extends StatelessWidget {
  final bool paroActivo;
  final VoidCallback onActivarParo;
  final VoidCallback onDesactivarParo;

  const EmergencyButtonWidget({
    super.key,
    required this.paroActivo,
    required this.onActivarParo,
    required this.onDesactivarParo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Estado actual del paro
          if (paroActivo)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.clayRed.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.clayRed.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.clayRed,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PARO DE EMERGENCIA ACTIVO',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.clayRed,
                                    letterSpacing: 0.8,
                                    fontSize: 12,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Todos los brazos robóticos detenidos',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.clayRed.withValues(alpha: 0.7),
                                    fontSize: 11,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .shimmer(
                  duration: 2000.ms,
                  color: AppColors.clayRed.withValues(alpha: 0.1),
                ),

          // ── Botón principal ──
          SizedBox(
            width: double.infinity,
            height: 56,
            child: paroActivo
                ? _buildResumeButton(context)
                : _buildEmergencyButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showConfirmDialog(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.clayRed,
        foregroundColor: AppColors.cream,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emergency_rounded, size: 22),
          const SizedBox(width: 10),
          Text(
            'PARO DE EMERGENCIA',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.cream,
                  letterSpacing: 1.2,
                  fontSize: 14,
                ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 400.ms);
  }

  Widget _buildResumeButton(BuildContext context) {
    return OutlinedButton(
      onPressed: onDesactivarParo,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.warmGreen,
        side: const BorderSide(
          color: AppColors.warmGreen,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_circle_outline_rounded, size: 22),
          const SizedBox(width: 10),
          Text(
            'REANUDAR OPERACIONES',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.warmGreen,
                  letterSpacing: 1.2,
                  fontSize: 14,
                ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  void _showConfirmDialog(BuildContext context) {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.clayRed.withValues(alpha: 0.3),
          ),
        ),
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.clayRed,
          size: 48,
        ),
        title: Text(
          '¿Activar Paro de Emergencia?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.cream,
              ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Esto detendrá inmediatamente todos los brazos robóticos. '
          'El café en preparación se interrumpirá.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.bone,
              ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancelar',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              HapticFeedback.heavyImpact();
              onActivarParo();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.clayRed,
              foregroundColor: AppColors.cream,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sí, detener todo'),
          ),
        ],
      ),
    );
  }
}
