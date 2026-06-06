import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';

/// Header del dashboard con título "Humanoid Coffee Co."
/// e indicador visual de la balanza (vaso que se llena).
class HeaderWidget extends StatelessWidget {
  final double pesoActual;
  final double pesoObjetivo;
  final bool paroEmergencia;

  const HeaderWidget({
    super.key,
    required this.pesoActual,
    required this.pesoObjetivo,
    this.paroEmergencia = false,
  });

  @override
  Widget build(BuildContext context) {
    final porcentaje = pesoObjetivo > 0
        ? (pesoActual / pesoObjetivo).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2A1F1A),
            AppColors.espresso,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Título ──
            Text(
              'Humanoid Coffee Co.',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    letterSpacing: 0.5,
                  ),
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .slideY(begin: -0.2, end: 0),

            const SizedBox(height: 4),
            Text(
              'Brazos robóticos al servicio del café',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                    letterSpacing: 1.5,
                    fontSize: 11,
                  ),
            ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

            const SizedBox(height: 28),

            // ── Indicador de balanza ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Vaso visual
                _CupIndicator(porcentaje: porcentaje),

                const SizedBox(width: 24),

                // Datos numéricos
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balanza',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                            letterSpacing: 1.2,
                            fontSize: 11,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: pesoActual),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return Text(
                              value.toStringAsFixed(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                    fontSize: 38,
                                    color: AppColors.caramel,
                                    fontWeight: FontWeight.w700,
                                  ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6, left: 4),
                          child: Text(
                            'g',
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.muted,
                                    ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (pesoObjetivo > 0)
                      Text(
                        'de ${pesoObjetivo.toStringAsFixed(0)}g objetivo',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.muted,
                            ),
                      ),

                    // Barra de progreso
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 140,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: porcentaje),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 6,
                              backgroundColor: AppColors.surfaceLight,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color.lerp(
                                  AppColors.caramel,
                                  AppColors.warmGreen,
                                  value,
                                )!,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ).animate().fadeIn(delay: 500.ms, duration: 700.ms),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Indicador visual del vaso que se llena
// ═══════════════════════════════════════════════════════════

class _CupIndicator extends StatelessWidget {
  final double porcentaje;

  const _CupIndicator({required this.porcentaje});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 100,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: porcentaje),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return CustomPaint(
            painter: _CupPainter(fillLevel: value),
            size: const Size(70, 100),
          );
        },
      ),
    );
  }
}

class _CupPainter extends CustomPainter {
  final double fillLevel;

  _CupPainter({required this.fillLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Forma del vaso (trapezoide redondeado) ──
    final cupPath = Path();
    final topInset = w * 0.08;
    final bottomInset = w * 0.18;
    final rimHeight = h * 0.08;
    final bodyTop = rimHeight;
    final bodyBottom = h - 8;
    final cornerRadius = 8.0;

    // Lado izquierdo, arriba → abajo
    cupPath.moveTo(topInset + cornerRadius, bodyTop);
    cupPath.lineTo(bottomInset + cornerRadius, bodyBottom - cornerRadius);
    cupPath.quadraticBezierTo(
        bottomInset, bodyBottom, bottomInset + cornerRadius, bodyBottom);

    // Fondo
    cupPath.lineTo(w - bottomInset - cornerRadius, bodyBottom);
    cupPath.quadraticBezierTo(w - bottomInset, bodyBottom,
        w - bottomInset - cornerRadius, bodyBottom - cornerRadius);

    // Lado derecho, abajo → arriba
    cupPath.lineTo(w - topInset - cornerRadius, bodyTop);

    // Borde superior
    cupPath.lineTo(topInset + cornerRadius, bodyTop);
    cupPath.close();

    // ── Sombra ──
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.save();
    canvas.translate(2, 3);
    canvas.drawPath(cupPath, shadowPaint);
    canvas.restore();

    // ── Fondo del vaso (vidrio) ──
    final glassPaint = Paint()
      ..color = const Color(0xFF3D2E24).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawPath(cupPath, glassPaint);

    // ── Líquido ──
    if (fillLevel > 0) {
      canvas.save();
      canvas.clipPath(cupPath);

      final liquidTop = bodyBottom - (bodyBottom - bodyTop) * fillLevel;
      final liquidRect = Rect.fromLTRB(0, liquidTop, w, bodyBottom);

      final liquidGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.coffeeFoam.withValues(alpha: 0.9),
          AppColors.coffeeLiquid,
          const Color(0xFF3A2518),
        ],
        stops: const [0.0, 0.15, 1.0],
      );

      final liquidPaint = Paint()
        ..shader = liquidGradient.createShader(liquidRect);
      canvas.drawRect(liquidRect, liquidPaint);

      // Onda sutil en la superficie del líquido
      final wavePaint = Paint()
        ..color = AppColors.coffeeFoam.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final wavePath = Path();
      wavePath.moveTo(0, liquidTop);
      for (var x = 0.0; x < w; x += 1) {
        wavePath.lineTo(x, liquidTop + sin(x * 0.15) * 1.5);
      }
      canvas.drawPath(wavePath, wavePaint);

      canvas.restore();
    }

    // ── Borde del vaso ──
    final borderPaint = Paint()
      ..color = AppColors.bone.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(cupPath, borderPaint);

    // ── Borde superior (rim) ──
    final rimPaint = Paint()
      ..color = AppColors.bone.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(topInset - 2, bodyTop),
      Offset(w - topInset + 2, bodyTop),
      rimPaint,
    );

    // ── Reflejo de vidrio ──
    final reflectPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(topInset, bodyTop, w * 0.3, h * 0.6));
    final reflectPath = Path();
    reflectPath.moveTo(topInset + 6, bodyTop + 4);
    reflectPath.lineTo(topInset + 14, bodyBottom - 16);
    reflectPath.lineTo(topInset + 22, bodyBottom - 16);
    reflectPath.lineTo(topInset + 14, bodyTop + 4);
    reflectPath.close();
    canvas.drawPath(reflectPath, reflectPaint);
  }

  @override
  bool shouldRepaint(covariant _CupPainter oldDelegate) =>
      oldDelegate.fillLevel != fillLevel;
}
