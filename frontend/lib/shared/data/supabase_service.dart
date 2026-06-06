import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_item_model.dart';
import '../models/pedido_model.dart';

/// Servicio centralizado para la comunicación con Supabase.
///
/// Tablas reales:
///   - `menu` → catálogo de bebidas
///   - `pedidos` → órdenes del usuario
///   - `detalle_pedidos` → ítems de cada pedido
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  // ═══════════════════════════════════════════════════════
  //  MENÚ (lectura)
  // ═══════════════════════════════════════════════════════

  /// Obtiene todas las bebidas disponibles del menú.
  Future<List<MenuItem>> fetchMenu() async {
    final response = await _client
        .from('menu')
        .select()
        .eq('disponible', true)
        .order('id', ascending: true);

    return (response as List)
        .map((json) => MenuItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Stream en tiempo real del menú (por si cambian disponibilidades).
  Stream<List<MenuItem>> menuStream() {
    return _client
        .from('menu')
        .stream(primaryKey: ['id'])
        .order('id', ascending: true)
        .map((data) {
          return data
              .where((item) => item['disponible'] == true)
              .map((json) => MenuItem.fromJson(json))
              .toList();
        });
  }

  // ═══════════════════════════════════════════════════════
  //  PEDIDOS (stream en tiempo real)
  // ═══════════════════════════════════════════════════════

  /// Stream de pedidos con detalles y nombre de menú (join).
  Stream<List<Pedido>> pedidosStream() {
    return _client
        .from('pedidos')
        .stream(primaryKey: ['id'])
        .order('creado_en', ascending: false)
        .asyncMap((pedidosData) async {
          // Para cada pedido, cargar sus detalles con join a menu
          final List<Pedido> pedidos = [];
          for (final pedidoJson in pedidosData) {
            final detallesResp = await _client
                .from('detalle_pedidos')
                .select('*, menu(nombre)')
                .eq('pedido_id', pedidoJson['id']);

            final detalles = (detallesResp as List)
                .map((d) => DetallePedido.fromJson(d as Map<String, dynamic>))
                .toList();

            pedidos.add(Pedido(
              id: pedidoJson['id'] as int,
              usuarioId: pedidoJson['usuario_id'] as String? ?? 'anon',
              estado: EstadoPedido.fromString(
                  pedidoJson['estado'] as String? ?? 'pendiente'),
              total: (pedidoJson['total'] as num?)?.toDouble() ?? 0.0,
              creadoEn: pedidoJson['creado_en'] != null
                  ? DateTime.tryParse(pedidoJson['creado_en'] as String)
                  : null,
              detalles: detalles,
            ));
          }
          return pedidos;
        });
  }

  // ═══════════════════════════════════════════════════════
  //  CREAR PEDIDO
  // ═══════════════════════════════════════════════════════

  /// Crea un nuevo pedido con un ítem del menú.
  Future<void> crearPedido({
    required int menuId,
    required double precio,
    int cantidad = 1,
  }) async {
    // 1. Crear el pedido
    final pedidoResp = await _client
        .from('pedidos')
        .insert({
          'usuario_id': 'anon',
          'estado': 'pendiente',
          'total': precio * cantidad,
        })
        .select('id')
        .single();

    final pedidoId = pedidoResp['id'] as int;

    // 2. Crear el detalle
    await _client.from('detalle_pedidos').insert({
      'pedido_id': pedidoId,
      'menu_id': menuId,
      'cantidad': cantidad,
      'subtotal': precio * cantidad,
    });
  }

  // ═══════════════════════════════════════════════════════
  //  ACTUALIZAR ESTADO DEL PEDIDO
  // ═══════════════════════════════════════════════════════

  /// Actualiza el estado de un pedido (para el botón de emergencia).
  Future<void> actualizarEstadoPedido(int pedidoId, String estado) async {
    await _client
        .from('pedidos')
        .update({'estado': estado})
        .eq('id', pedidoId);
  }
}
