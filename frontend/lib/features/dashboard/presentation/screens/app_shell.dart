import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'menu_screen.dart';
import 'pedidos_screen.dart';
import 'robot_screen.dart';

/// Shell principal con NavigationBar de 3 pestañas
/// y botón de emergencia persistente.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  bool _paroActivo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.espresso,
      body: Stack(
        children: [
          // ── Contenido de la pestaña activa ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.03, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildCurrentScreen(),
          ),

          // ── Banner de emergencia (superpuesto si activo) ──
          if (_paroActivo)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: _buildEmergencyBanner(context),
            ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Botón de emergencia persistente ──
          _buildEmergencyButton(context),

          // ── Navigation Bar ──
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.surfaceLight.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              backgroundColor: Colors.transparent,
              indicatorColor: AppColors.caramel.withValues(alpha: 0.15),
              surfaceTintColor: Colors.transparent,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              height: 68,
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.coffee_outlined,
                      color: _currentIndex == 0 ? AppColors.caramel : AppColors.muted),
                  selectedIcon: const Icon(Icons.coffee, color: AppColors.caramel),
                  label: 'Menú',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined,
                      color: _currentIndex == 1 ? AppColors.caramel : AppColors.muted),
                  selectedIcon:
                      const Icon(Icons.receipt_long, color: AppColors.caramel),
                  label: 'Pedidos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.smart_toy_outlined,
                      color: _currentIndex == 2 ? AppColors.caramel : AppColors.muted),
                  selectedIcon: const Icon(Icons.smart_toy, color: AppColors.caramel),
                  label: 'Robot',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return MenuScreen(
          key: const ValueKey('menu'),
          onPedidoCreado: () {
            // Navegar automáticamente a pedidos tras crear uno
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) setState(() => _currentIndex = 1);
            });
          },
        );
      case 1:
        return const PedidosScreen(key: ValueKey('pedidos'));
      case 2:
        return const RobotScreen(key: ValueKey('robot'));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmergencyButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      color: AppColors.surface,
      child: SizedBox(
        height: 44,
        child: _paroActivo
            ? OutlinedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  setState(() => _paroActivo = false);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warmGreen,
                  side: const BorderSide(color: AppColors.warmGreen, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_circle_outline_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'REANUDAR OPERACIONES',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              )
            : ElevatedButton(
                onPressed: () => _showEmergencyDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.clayRed,
                  foregroundColor: AppColors.cream,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emergency_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'PARO DE EMERGENCIA',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEmergencyBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 8, 20, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.clayRed.withValues(alpha: 0.95),
            AppColors.clayRed.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'PARO DE EMERGENCIA ACTIVO — Brazos detenidos',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -1, end: 0, duration: 400.ms, curve: Curves.easeOut)
        .then()
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 2500.ms, color: Colors.white.withValues(alpha: 0.1));
  }

  void _showEmergencyDialog(BuildContext context) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.clayRed.withValues(alpha: 0.3)),
        ),
        icon: const Icon(Icons.warning_amber_rounded, color: AppColors.clayRed, size: 48),
        title: Text(
          '¿Activar Paro de Emergencia?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.cream),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Esto detendrá inmediatamente todos los brazos robóticos. '
          'El café en preparación se interrumpirá.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.bone),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar',
                style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              HapticFeedback.heavyImpact();
              setState(() => _paroActivo = true);
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
