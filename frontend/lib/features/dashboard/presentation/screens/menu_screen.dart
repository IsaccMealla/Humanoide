import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/data/supabase_service.dart';
import '../../../../shared/models/menu_item_model.dart';

/// Pantalla del menú con grid de 2 columnas de bebidas disponibles.
class MenuScreen extends StatefulWidget {
  final VoidCallback? onPedidoCreado;

  const MenuScreen({super.key, this.onPedidoCreado});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _service = SupabaseService.instance;
  List<MenuItem> _items = [];
  bool _isLoading = true;
  int? _preparandoId;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    try {
      final items = await _service.fetchMenu();
      if (mounted) setState(() { _items = items; _isLoading = false; });
    } catch (e) {
      debugPrint('Error cargando menú: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onPreparar(MenuItem item) async {
    setState(() => _preparandoId = item.id);
    try {
      await _service.crearPedido(menuId: item.id, precio: item.precio);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text('${item.emoji}  ', style: const TextStyle(fontSize: 18)),
                Expanded(child: Text('¡${item.nombre} en camino!')),
              ],
            ),
            backgroundColor: AppColors.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        widget.onPedidoCreado?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al crear el pedido'),
            backgroundColor: AppColors.clayRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _preparandoId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      'Humanoid Coffee Co.',
                      style: Theme.of(context).textTheme.displayMedium,
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.15, end: 0),
                    const SizedBox(height: 6),
                    Text(
                      'Elige tu bebida favorita',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.muted,
                          ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                    const SizedBox(height: 16),
                    // Indicador de cantidad
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.caramel.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('☕', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(
                            '${_items.length} bebidas disponibles',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.caramelLight,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                  ],
                ),
              ),
            ),
          ),

          // ── Grid de bebidas ──
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.caramel,
                  strokeWidth: 2.5,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _items[index];
                    return _MenuCard(
                      item: item,
                      index: index,
                      isPreparando: _preparandoId == item.id,
                      onPreparar: () => _onPreparar(item),
                    );
                  },
                  childCount: _items.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Tarjeta de menú individual
// ═══════════════════════════════════════════════════════════

class _MenuCard extends StatelessWidget {
  final MenuItem item;
  final int index;
  final bool isPreparando;
  final VoidCallback onPreparar;

  const _MenuCard({
    required this.item,
    required this.index,
    required this.isPreparando,
    required this.onPreparar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF322520), AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.surfaceLight.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.caramel.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(item.emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(height: 12),

            // Nombre
            Text(
              item.nombre,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Descripción
            Expanded(
              child: Text(
                item.descripcion,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                      fontSize: 11,
                      height: 1.3,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 8),

            // Precio
            Text(
              '${item.precio.toStringAsFixed(0)} Bs',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.caramel,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
            ),

            const SizedBox(height: 10),

            // Botón
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPreparando ? null : onPreparar,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor:
                      AppColors.surfaceLight.withValues(alpha: 0.5),
                ),
                child: isPreparando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.caramel,
                        ),
                      )
                    : const Text('Preparar ☕', style: TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 + index * 80),
          duration: 500.ms,
        )
        .scaleXY(
          begin: 0.92,
          end: 1.0,
          delay: Duration(milliseconds: 100 + index * 80),
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
