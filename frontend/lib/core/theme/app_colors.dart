import 'package:flutter/material.dart';

/// Paleta de colores "Warm Coffee" para Humanoid Coffee Co.
class AppColors {
  AppColors._();

  // ── Fondos ──────────────────────────────────────────────
  /// Espresso oscuro — fondo principal
  static const Color espresso = Color(0xFF1A0F0A);

  /// Café tostado — superficies elevadas (cards, panels)
  static const Color surface = Color(0xFF2A1F1A);

  /// Café medio — bordes sutiles, divisores
  static const Color surfaceLight = Color(0xFF3D2E24);

  // ── Textos ──────────────────────────────────────────────
  /// Crema/Leche — texto principal
  static const Color cream = Color(0xFFF5EBE6);

  /// Hueso suave — texto secundario
  static const Color bone = Color(0xFFD4C5BB);

  /// Café con leche — texto terciario / placeholders
  static const Color muted = Color(0xFF9C8B80);

  // ── Acentos ─────────────────────────────────────────────
  /// Caramelo/Avellana — color de acento principal
  static const Color caramel = Color(0xFFC68B59);

  /// Caramelo claro — hover / pressed states
  static const Color caramelLight = Color(0xFFD9A876);

  /// Caramelo oscuro — variante más profunda
  static const Color caramelDark = Color(0xFFA6703F);

  // ── Estados ─────────────────────────────────────────────
  /// Rojo arcilla mate — emergencia / paro
  static const Color clayRed = Color(0xFFA63D2F);

  /// Rojo arcilla claro — hover del botón de emergencia
  static const Color clayRedLight = Color(0xFFC04D3D);

  /// Verde oliva cálido — éxito / completado
  static const Color warmGreen = Color(0xFF6B8F4E);

  /// Ámbar cálido — en proceso / advertencia
  static const Color warmAmber = Color(0xFFD4A03C);

  // ── Indicador de líquido (balanza) ──────────────────────
  /// Color del líquido del café en el vaso
  static const Color coffeeLiquid = Color(0xFF5C3D2E);

  /// Color de la espuma / crema del café
  static const Color coffeeFoam = Color(0xFFD4B896);
}
