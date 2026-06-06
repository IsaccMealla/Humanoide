/// Estados posibles de un pedido, mapeando el flujo del robot barista.
enum EstadoPedido {
  pendiente('pendiente', 'Pendiente', '📋', 'Orden recibida por el sistema'),
  preparando('preparando', 'Preparando', '☕', 'El robot está sirviendo tu café'),
  listo('listo', 'Listo', '✅', 'Tu café está listo para recoger'),
  entregado('entregado', 'Entregado', '🎉', 'Café entregado. ¡Disfruta!');

  final String value;
  final String label;
  final String emoji;
  final String descripcion;

  const EstadoPedido(this.value, this.label, this.emoji, this.descripcion);

  int get stepIndex => index;

  static EstadoPedido fromString(String value) {
    return EstadoPedido.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EstadoPedido.pendiente,
    );
  }
}

/// Modelo que mapea la tabla `pedidos` de Supabase.
class Pedido {
  final int id;
  final String usuarioId;
  final EstadoPedido estado;
  final double total;
  final DateTime? creadoEn;
  final List<DetallePedido> detalles;

  const Pedido({
    required this.id,
    required this.usuarioId,
    required this.estado,
    required this.total,
    this.creadoEn,
    this.detalles = const [],
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    List<DetallePedido> detalles = [];
    if (json['detalle_pedidos'] != null) {
      detalles = (json['detalle_pedidos'] as List)
          .map((d) => DetallePedido.fromJson(d as Map<String, dynamic>))
          .toList();
    }

    return Pedido(
      id: json['id'] as int,
      usuarioId: json['usuario_id'] as String? ?? 'anon',
      estado: EstadoPedido.fromString(json['estado'] as String? ?? 'pendiente'),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      creadoEn: json['creado_en'] != null
          ? DateTime.tryParse(json['creado_en'] as String)
          : null,
      detalles: detalles,
    );
  }

  /// Si el pedido está activo (no entregado).
  bool get isActive =>
      estado != EstadoPedido.entregado && estado != EstadoPedido.listo;

  /// Nombre descriptivo del pedido (primer ítem o genérico).
  String get nombreDisplay {
    if (detalles.isNotEmpty && detalles.first.menuNombre != null) {
      return detalles.first.menuNombre!;
    }
    return 'Pedido #$id';
  }
}

/// Modelo que mapea la tabla `detalle_pedidos` de Supabase.
class DetallePedido {
  final int id;
  final int pedidoId;
  final int menuId;
  final int cantidad;
  final double subtotal;
  final String? menuNombre;

  const DetallePedido({
    required this.id,
    required this.pedidoId,
    required this.menuId,
    required this.cantidad,
    required this.subtotal,
    this.menuNombre,
  });

  factory DetallePedido.fromJson(Map<String, dynamic> json) {
    // Si viene con join de menu
    String? menuNombre;
    if (json['menu'] != null && json['menu'] is Map) {
      menuNombre = (json['menu'] as Map<String, dynamic>)['nombre'] as String?;
    }

    return DetallePedido(
      id: json['id'] as int,
      pedidoId: json['pedido_id'] as int? ?? 0,
      menuId: json['menu_id'] as int? ?? 0,
      cantidad: json['cantidad'] as int? ?? 1,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      menuNombre: menuNombre,
    );
  }
}
