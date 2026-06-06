/// Los estados posibles de una orden, mapeando el flujo
/// de los brazos robóticos del barista.
enum EstadoOrden {
  recibida('recibida', 'Orden recibida', '📋'),
  colocandoVaso('colocando_vaso', 'Colocando vaso', '🥛'),
  sirviendoIngredientes('sirviendo_ingredientes', 'Sirviendo ingredientes', '☕'),
  trasladandoACinta('trasladando_a_cinta', 'Trasladando a cinta', '🤖'),
  entregado('entregado', 'Entregado', '✅');

  final String value;
  final String label;
  final String emoji;

  const EstadoOrden(this.value, this.label, this.emoji);

  /// Índice del paso (0-based) para el stepper.
  int get stepIndex => index;

  static EstadoOrden fromString(String value) {
    return EstadoOrden.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EstadoOrden.recibida,
    );
  }
}

/// Modelo que mapea la tabla `tabla_ordenes` de Supabase.
class Orden {
  final int id;
  final int recetaId;
  final String nombreCafe;
  final EstadoOrden estado;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Orden({
    required this.id,
    required this.recetaId,
    required this.nombreCafe,
    required this.estado,
    this.createdAt,
    this.updatedAt,
  });

  factory Orden.fromJson(Map<String, dynamic> json) {
    return Orden(
      id: json['id'] as int,
      recetaId: json['receta_id'] as int? ?? 0,
      nombreCafe: json['nombre_cafe'] as String? ?? '',
      estado: EstadoOrden.fromString(json['estado'] as String? ?? 'recibida'),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Si la orden está activa (no entregada aún).
  bool get isActive => estado != EstadoOrden.entregado;
}
