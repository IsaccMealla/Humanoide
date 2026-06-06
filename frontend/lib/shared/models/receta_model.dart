/// Modelo que mapea la tabla `tabla_recetas` de Supabase.
class Receta {
  final int id;
  final String nombre;
  final String descripcion;
  final String icono;
  final double pesoObjetivoG;

  const Receta({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.pesoObjetivoG,
  });

  factory Receta.fromJson(Map<String, dynamic> json) {
    return Receta(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      icono: json['icono'] as String? ?? '☕',
      pesoObjetivoG: (json['peso_objetivo_g'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'peso_objetivo_g': pesoObjetivoG,
    };
  }
}
