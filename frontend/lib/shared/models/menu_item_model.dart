/// Modelo que mapea la tabla `menu` de Supabase.
class MenuItem {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String? imagen;
  final bool disponible;
  final DateTime? creadoEn;

  const MenuItem({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.imagen,
    this.disponible = true,
    this.creadoEn,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as int,
      nombre: json['nombre'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      imagen: json['imagen'] as String?,
      disponible: json['disponible'] as bool? ?? true,
      creadoEn: json['creado_en'] != null
          ? DateTime.tryParse(json['creado_en'] as String)
          : null,
    );
  }

  /// Retorna un emoji representativo según el nombre de la bebida.
  String get emoji {
    final lower = nombre.toLowerCase();
    if (lower.contains('espresso')) return '☕';
    if (lower.contains('cappuccino')) return '☕';
    if (lower.contains('latte')) return '🥛';
    if (lower.contains('mocha')) return '🍫';
    if (lower.contains('americano')) return '☕';
    if (lower.contains('flat white')) return '🤍';
    if (lower.contains('chocolate')) return '🍫';
    if (lower.contains('matcha')) return '🍵';
    if (lower.contains('cold brew')) return '🧊';
    if (lower.contains('affogato')) return '🍨';
    if (lower.contains('irish')) return '🥃';
    if (lower.contains('caramel')) return '🍯';
    if (lower.contains('miel')) return '🍯';
    if (lower.contains('chai')) return '🫖';
    if (lower.contains('te ') || lower.contains('té')) return '🍵';
    if (lower.contains('jugo') || lower.contains('naranja')) return '🍊';
    if (lower.contains('agua')) return '💧';
    return '☕';
  }
}
