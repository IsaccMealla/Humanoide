import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/data/supabase_service.dart';
import '../../../../shared/models/pedido_model.dart';

/// Pantalla del estado del robot con indicador visual de balanza
/// y progreso detallado del pedido activo.
class RobotScreen extends StatefulWidget {
  const RobotScreen({super.key});

  @override
  State<RobotScreen> createState() => _RobotScreenState();
}

class _RobotScreenState extends State<RobotScreen> {
  final _service = SupabaseService.instance;
  List<Pedido> _pedidos = [];
  bool _isLoading = true;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _sub = _service.pedidosStream().listen(
      (pedidos) {
        if (mounted) setState(() { _pedidos = pedidos; _isLoading = false; });
      },
      onError: (e) {
        debugPrint('Error stream robot: $e');
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Pedido? get _pedidoActivo {
    try {
      return _pedidos.firstWhere((p) => p.isActive);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedido = _pedidoActivo;
    final progreso = pedido != null
        ? (pedido.estado.stepIndex / (EstadoPedido.values.length - 1)).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.espresso,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2A1F1A), AppColors.espresso],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado del Robot',
                      style: Theme.of(context).textTheme.displayMedium,
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.15, end: 0),
                    const SizedBox(height: 6),
                    Text(
                      'Brazos robóticos en tiempo real',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.muted,
                          ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.caramel,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // ── Indicador de conexión ──
                        _buildConnectionStatus(context),

                        const SizedBox(height: 24),

                        // ── Vaso / Balanza visual ──
                        _buildCupSection(context, progreso, pedido),

                        const SizedBox(height: 28),

                        // ── Timeline vertical detallado ──
                        _buildDetailedTimeline(context, pedido),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          // Indicador pulsante
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.warmGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.warmGreen.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.3, duration: 1200.ms),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Robot conectado',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                ),
                Text(
                  'Supabase Realtime activo • Brazos operativos',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.warmGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'ONLINE',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.warmGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms);
  }

  Widget _buildCupSection(BuildContext context, double progreso, Pedido? pedido) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E2018), AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceLight.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            pedido != null ? 'Preparando: ${pedido.nombreDisplay}' : 'Esperando orden...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: pedido != null ? AppColors.cream : AppColors.muted,
                ),
          ),
          const SizedBox(height: 24),

          // Vaso visual
          SizedBox(
            width: 100,
            height: 140,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progreso),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CustomPaint(
                  painter: _CupPainter(fillLevel: value),
                  size: const Size(100, 140),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Progreso porcentual
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progreso),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, _) {
              return Text(
                '${(value * 100).toInt()}%',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 36,
                      color: AppColors.caramel,
                    ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            pedido?.estado.descripcion ?? 'Robot en espera',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                ),
          ),

          const SizedBox(height: 16),

          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progreso),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.lerp(AppColors.caramel, AppColors.warmGreen, value)!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 600.ms);
  }

  Widget _buildDetailedTimeline(BuildContext context, Pedido? pedido) {
    final currentStep = pedido?.estado.stepIndex ?? -1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceLight.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                'Proceso detallado',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 18),

          ...EstadoPedido.values.asMap().entries.map((entry) {
            final idx = entry.key;
            final paso = entry.value;
            final isCompleted = idx < currentStep;
            final isActive = idx == currentStep;
            final isLast = idx == EstadoPedido.values.length - 1;

            return _TimelineStep(
              paso: paso,
              isCompleted: isCompleted,
              isActive: isActive,
              isLast: isLast,
              delay: idx * 120,
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms, duration: 500.ms);
  }
}

// ═══════════════════════════════════════════════════════════
//  Paso del timeline vertical
// ═══════════════════════════════════════════════════════════

class _TimelineStep extends StatelessWidget {
  final EstadoPedido paso;
  final bool isCompleted;
  final bool isActive;
  final bool isLast;
  final int delay;

  const _TimelineStep({
    required this.paso,
    required this.isCompleted,
    required this.isActive,
    required this.isLast,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = !isCompleted && !isActive;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicador + línea
          SizedBox(
            width: 36,
            child: Column(
              children: [
                _buildDot(),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? AppColors.warmGreen : AppColors.surfaceLight,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Contenido
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(paso.emoji, style: TextStyle(
                        fontSize: 16,
                        color: isPending ? AppColors.muted : null,
                      )),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          paso.label,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: isPending ? AppColors.muted : AppColors.cream,
                                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    paso.descripcion,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isPending
                              ? AppColors.muted.withValues(alpha: 0.5)
                              : AppColors.muted,
                          fontSize: 11,
                        ),
                  ),
                  if (isActive)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.caramel.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'En curso...',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.caramelLight,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .shimmer(
                            duration: 1800.ms,
                            color: AppColors.caramel.withValues(alpha: 0.3),
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
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideX(begin: -0.05, end: 0, delay: Duration(milliseconds: delay), duration: 400.ms);
  }

  Widget _buildDot() {
    if (isCompleted) {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.warmGreen,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: AppColors.warmGreen.withValues(alpha: 0.3), blurRadius: 6),
          ],
        ),
        child: const Icon(Icons.check, size: 14, color: Colors.white),
      );
    }

    if (isActive) {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.caramel,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: AppColors.caramel.withValues(alpha: 0.4), blurRadius: 8),
          ],
        ),
        child: const Icon(Icons.play_arrow_rounded, size: 14, color: AppColors.espresso),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 1.0, end: 1.15, duration: 1000.ms);
    }

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surfaceLight, width: 2),
      ),
      child: Center(
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: AppColors.surfaceLight,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  CustomPainter del vaso
// ═══════════════════════════════════════════════════════════

class _CupPainter extends CustomPainter {
  final double fillLevel;
  _CupPainter({required this.fillLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final topInset = w * 0.08;
    final bottomInset = w * 0.18;
    final rimHeight = h * 0.06;
    final bodyTop = rimHeight;
    final bodyBottom = h - 8;

    // Forma del vaso
    final cupPath = Path()
      ..moveTo(topInset + 8, bodyTop)
      ..lineTo(bottomInset + 8, bodyBottom - 8)
      ..quadraticBezierTo(bottomInset, bodyBottom, bottomInset + 8, bodyBottom)
      ..lineTo(w - bottomInset - 8, bodyBottom)
      ..quadraticBezierTo(w - bottomInset, bodyBottom, w - bottomInset - 8, bodyBottom - 8)
      ..lineTo(w - topInset - 8, bodyTop)
      ..lineTo(topInset + 8, bodyTop)
      ..close();

    // Sombra
    canvas.save();
    canvas.translate(2, 4);
    canvas.drawPath(cupPath, Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.restore();

    // Vidrio
    canvas.drawPath(cupPath, Paint()
      ..color = const Color(0xFF3D2E24).withValues(alpha: 0.5));

    // Líquido
    if (fillLevel > 0) {
      canvas.save();
      canvas.clipPath(cupPath);
      final liquidTop = bodyBottom - (bodyBottom - bodyTop) * fillLevel;
      final liquidPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.coffeeFoam.withValues(alpha: 0.9),
            AppColors.coffeeLiquid,
            const Color(0xFF3A2518),
          ],
          stops: const [0.0, 0.12, 1.0],
        ).createShader(Rect.fromLTRB(0, liquidTop, w, bodyBottom));
      canvas.drawRect(Rect.fromLTRB(0, liquidTop, w, bodyBottom), liquidPaint);

      // Onda
      final wavePaint = Paint()
        ..color = AppColors.coffeeFoam.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final wavePath = Path()..moveTo(0, liquidTop);
      for (var x = 0.0; x < w; x += 1) {
        wavePath.lineTo(x, liquidTop + sin(x * 0.12) * 2);
      }
      canvas.drawPath(wavePath, wavePaint);
      canvas.restore();
    }

    // Borde
    canvas.drawPath(cupPath, Paint()
      ..color = AppColors.bone.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    // Rim
    canvas.drawLine(
      Offset(topInset - 2, bodyTop),
      Offset(w - topInset + 2, bodyTop),
      Paint()
        ..color = AppColors.bone.withValues(alpha: 0.5)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Reflejo
    final reflectPath = Path()
      ..moveTo(topInset + 8, bodyTop + 6)
      ..lineTo(topInset + 16, bodyBottom - 20)
      ..lineTo(topInset + 24, bodyBottom - 20)
      ..lineTo(topInset + 16, bodyTop + 6)
      ..close();
    canvas.drawPath(reflectPath, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(topInset, bodyTop, w * 0.3, h * 0.6)));
  }

  @override
  bool shouldRepaint(covariant _CupPainter oldDelegate) =>
      oldDelegate.fillLevel != fillLevel;
}
