import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/receta_model.dart';

/// Grid horizontal de tarjetas con las recetas de café disponibles.
/// Cada tarjeta tiene un botón "Preparar ☕" que dispara la creación
/// de una orden en Supabase.
class MenuGridWidget extends StatelessWidget {
  final List<Receta> recetas;
  final bool ordenActiva;
  final ValueChanged<Receta> onPreparar;

  const MenuGridWidget({
    super.key,
    required this.recetas,
    required this.ordenActiva,
    required this.onPreparar,
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
                'Menú del día',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Selecciona tu café favorito',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          // ── Grid horizontal ──
          SizedBox(
            height: 210,
            child: recetas.isEmpty
                ? Center(
                    child: Text(
                      'Cargando recetas...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.muted,
                          ),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: recetas.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      return _RecetaCard(
                        receta: recetas[index],
                        index: index,
                        ordenActiva: ordenActiva,
                        onPreparar: onPreparar,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  Tarjeta individual de receta
// ═══════════════════════════════════════════════════════════

class _RecetaCard extends StatefulWidget {
  final Receta receta;
  final int index;
  final bool ordenActiva;
  final ValueChanged<Receta> onPreparar;

  const _RecetaCard({
    required this.receta,
    required this.index,
    required this.ordenActiva,
    required this.onPreparar,
  });

  @override
  State<_RecetaCard> createState() => _RecetaCardState();
}

class _RecetaCardState extends State<_RecetaCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Container(
        width: 165,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF322520),
              AppColors.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.surfaceLight.withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono grande
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.caramel.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    widget.receta.icono,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Nombre
              Text(
                widget.receta.nombre,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Descripción
              Text(
                widget.receta.descripcion,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // Botón Preparar
              GestureDetector(
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.ordenActiva
                        ? null
                        : () => widget.onPreparar(widget.receta),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor:
                          AppColors.surfaceLight.withValues(alpha: 0.5),
                      disabledForegroundColor: AppColors.muted,
                    ),
                    child: Text(
                      widget.ordenActiva ? 'En proceso...' : 'Preparar ☕',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 200 + widget.index * 100),
          duration: 500.ms,
        )
        .slideX(
          begin: 0.15,
          end: 0,
          delay: Duration(milliseconds: 200 + widget.index * 100),
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
