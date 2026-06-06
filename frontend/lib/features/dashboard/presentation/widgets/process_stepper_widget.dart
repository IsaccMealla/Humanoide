import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/orden_model.dart';

/// Stepper vertical tipo timeline que muestra el progreso
/// de la orden a través de los brazos robóticos.
class ProcessStepperWidget extends StatelessWidget {
  final Orden? ordenActiva;

  const ProcessStepperWidget({
    super.key,
    this.ordenActiva,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Título de sección ──
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.caramel,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Monitor de proceso',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (ordenActiva != null)
            Text(
              'Preparando: ${ordenActiva!.nombreCafe}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.caramelLight,
                  ),
            )
          else
            Text(
              'Esperando una nueva orden...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 20),

          // ── Timeline ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.surfaceLight.withValues(alpha: 0.5),
              ),
            ),
            child: ordenActiva == null
                ? _buildIdleState(context)
                : _buildTimeline(context),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const Text(
            '☕',
            style: TextStyle(fontSize: 40),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.1, duration: 1500.ms)
              .then()
              .scaleXY(begin: 1.1, end: 1.0, duration: 1500.ms),
          const SizedBox(height: 12),
          Text(
            'Robot en espera',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.bone,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Selecciona un café del menú para comenzar',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final currentStep = ordenActiva!.estado.stepIndex;

    return Column(
      children: EstadoOrden.values.asMap().entries.map((entry) {
        final index = entry.key;
        final paso = entry.value;
        final isCompleted = index < currentStep;
        final isActive = index == currentStep;
        final isPending = index > currentStep;
        final isLast = index == EstadoOrden.values.length - 1;

        return _TimelineStep(
          paso: paso,
          isCompleted: isCompleted,
          isActive: isActive,
          isPending: isPending,
          isLast: isLast,
          animationDelay: index * 120,
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Paso individual del timeline
// ═══════════════════════════════════════════════════════════

class _TimelineStep extends StatelessWidget {
  final EstadoOrden paso;
  final bool isCompleted;
  final bool isActive;
  final bool isPending;
  final bool isLast;
  final int animationDelay;

  const _TimelineStep({
    required this.paso,
    required this.isCompleted,
    required this.isActive,
    required this.isPending,
    required this.isLast,
    required this.animationDelay,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Columna de indicador + línea ──
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Indicador circular
                _buildIndicator(),
                // Línea conectora
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isCompleted
                              ? [AppColors.warmGreen, AppColors.warmGreen]
                              : isActive
                                  ? [
                                      AppColors.caramel,
                                      AppColors.surfaceLight,
                                    ]
                                  : [
                                      AppColors.surfaceLight,
                                      AppColors.surfaceLight,
                                    ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // ── Contenido del paso ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emoji + Nombre del paso
                  Row(
                    children: [
                      Text(
                        paso.emoji,
                        style: TextStyle(
                          fontSize: 16,
                          color: isPending
                              ? AppColors.muted
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          paso.label,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: isPending
                                        ? AppColors.muted
                                        : isActive
                                            ? AppColors.cream
                                            : AppColors.bone,
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                        ),
                      ),
                    ],
                  ),

                  // Estado textual
                  if (isActive)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.caramel.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'En curso...',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.caramelLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .fadeIn(duration: 300.ms)
                          .then()
                          .shimmer(
                            duration: 1800.ms,
                            color: AppColors.caramel.withValues(alpha: 0.3),
                          ),
                    ),

                  if (isCompleted)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Completado ✓',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.warmGreen,
                              fontSize: 11,
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: animationDelay),
          duration: 400.ms,
        )
        .slideX(
          begin: -0.05,
          end: 0,
          delay: Duration(milliseconds: animationDelay),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildIndicator() {
    if (isCompleted) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.warmGreen,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.warmGreen.withValues(alpha: 0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Icon(Icons.check, size: 16, color: Colors.white),
      );
    }

    if (isActive) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.caramel,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.caramel.withValues(alpha: 0.4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.play_arrow_rounded,
            size: 16, color: AppColors.espresso),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.15,
            duration: 1000.ms,
            curve: Curves.easeInOut,
          );
    }

    // Pending
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.surfaceLight,
          width: 2,
        ),
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.surfaceLight,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
