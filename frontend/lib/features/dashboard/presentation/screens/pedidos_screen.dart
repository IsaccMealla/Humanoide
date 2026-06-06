import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/data/supabase_service.dart';
import '../../../../shared/models/pedido_model.dart';

/// Pantalla de pedidos con lista en tiempo real y stepper de proceso.
class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
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
        debugPrint('Error stream pedidos: $e');
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Separar activos de completados
    final activos = _pedidos.where((p) => p.isActive).toList();
    final completados = _pedidos.where((p) => !p.isActive).toList();

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
                      'Tus Pedidos',
                      style: Theme.of(context).textTheme.displayMedium,
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.15, end: 0),
                    const SizedBox(height: 6),
                    Text(
                      'Seguimiento en tiempo real',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.muted,
                          ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                  ],
                ),
              ),
            ),
          ),

          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.caramel,
                  strokeWidth: 2.5,
                ),
              ),
            )
          else if (_pedidos.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(context),
            )
          else ...[
            // ── Pedidos activos ──
            if (activos.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionTitle(context, 'En proceso', '🔥', activos.length),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _PedidoCard(
                    pedido: activos[index],
                    index: index,
                    showStepper: true,
                  ),
                  childCount: activos.length,
                ),
              ),
            ],

            // ── Pedidos completados ──
            if (completados.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionTitle(context, 'Completados', '✅', completados.length),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _PedidoCard(
                    pedido: completados[index],
                    index: index,
                    showStepper: false,
                  ),
                  childCount: completados.length,
                ),
              ),
            ],

            // Espacio inferior
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📋', style: TextStyle(fontSize: 48))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.1, duration: 1500.ms),
          const SizedBox(height: 16),
          Text(
            'No hay pedidos aún',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.bone,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ve al menú y selecciona tu café favorito',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, String emoji, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
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
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.caramelLight,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Tarjeta de pedido con stepper integrado
// ═══════════════════════════════════════════════════════════

class _PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final int index;
  final bool showStepper;

  const _PedidoCard({
    required this.pedido,
    required this.index,
    required this.showStepper,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: pedido.isActive
              ? AppColors.caramel.withValues(alpha: 0.25)
              : AppColors.surfaceLight.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado del pedido ──
          Row(
            children: [
              // Emoji del estado
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _estadoColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    pedido.estado.emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pedido.nombreDisplay,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pedido #${pedido.id}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),

              // Precio + Estado chip
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${pedido.total.toStringAsFixed(0)} Bs',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.caramel,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  _EstadoChip(estado: pedido.estado),
                ],
              ),
            ],
          ),

          // ── Stepper mini ──
          if (showStepper) ...[
            const SizedBox(height: 18),
            _MiniStepper(estadoActual: pedido.estado),
          ],

          // ── Hora ──
          if (pedido.creadoEn != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 13, color: AppColors.muted.withValues(alpha: 0.6)),
                const SizedBox(width: 4),
                Text(
                  _formatTime(pedido.creadoEn!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.muted.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 80 * index),
          duration: 400.ms,
        )
        .slideX(
          begin: -0.04,
          end: 0,
          delay: Duration(milliseconds: 80 * index),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  Color get _estadoColor {
    switch (pedido.estado) {
      case EstadoPedido.pendiente:
        return AppColors.warmAmber;
      case EstadoPedido.preparando:
        return AppColors.caramel;
      case EstadoPedido.listo:
        return AppColors.warmGreen;
      case EstadoPedido.entregado:
        return AppColors.muted;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ═══════════════════════════════════════════════════════════
//  Chip de estado
// ═══════════════════════════════════════════════════════════

class _EstadoChip extends StatelessWidget {
  final EstadoPedido estado;

  const _EstadoChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    switch (estado) {
      case EstadoPedido.pendiente:
        chipColor = AppColors.warmAmber;
      case EstadoPedido.preparando:
        chipColor = AppColors.caramel;
      case EstadoPedido.listo:
        chipColor = AppColors.warmGreen;
      case EstadoPedido.entregado:
        chipColor = AppColors.muted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        estado.label,
        style: TextStyle(
          color: chipColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Mini stepper horizontal
// ═══════════════════════════════════════════════════════════

class _MiniStepper extends StatelessWidget {
  final EstadoPedido estadoActual;

  const _MiniStepper({required this.estadoActual});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: EstadoPedido.values.asMap().entries.map((entry) {
        final idx = entry.key;
        final isCompleted = idx < estadoActual.stepIndex;
        final isActive = idx == estadoActual.stepIndex;
        final isLast = idx == EstadoPedido.values.length - 1;

        return Expanded(
          child: Row(
            children: [
              // Dot
              _buildDot(isCompleted, isActive),
              // Line
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.warmGreen.withValues(alpha: 0.7)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDot(bool isCompleted, bool isActive) {
    if (isCompleted) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.warmGreen,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.warmGreen.withValues(alpha: 0.3),
              blurRadius: 4,
            ),
          ],
        ),
        child: const Icon(Icons.check, size: 12, color: Colors.white),
      );
    }

    if (isActive) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.caramel,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.caramel.withValues(alpha: 0.4),
              blurRadius: 6,
            ),
          ],
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 1.0, end: 1.2, duration: 800.ms);
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surfaceLight, width: 2),
      ),
    );
  }
}
