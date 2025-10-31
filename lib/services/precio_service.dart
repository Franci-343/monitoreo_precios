import '../models/precio_model.dart';
import '../services/auth_service.dart';
import '../main.dart';

class PrecioService {
  // Singleton pattern
  static final PrecioService _instance = PrecioService._internal();
  factory PrecioService() => _instance;
  PrecioService._internal();

  final _authService = AuthService();

  // ============================================
  // OBTENER PRECIOS DE UN PRODUCTO
  // ============================================
  Future<List<Precio>> getPreciosProducto(int productoId) async {
    try {
      final response = await supabase
          .from('precios')
          .select('*')
          .eq('producto_id', productoId)
          .order('fecha_actualizacion', ascending: false);

      return (response as List).map((json) => Precio.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener precios: $e');
    }
  }

  // ============================================
  // OBTENER PRECIOS POR PRODUCTO Y MERCADO
  // ============================================
  Future<List<Precio>> getPreciosPorProductoYMercado(
    int productoId,
    int mercadoId,
  ) async {
    try {
      final response = await supabase
          .from('precios')
          .select('*')
          .eq('producto_id', productoId)
          .eq('mercado_id', mercadoId)
          .order('fecha_actualizacion', ascending: false);

      return (response as List).map((json) => Precio.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener precios: $e');
    }
  }

  // ============================================
  // OBTENER PRECIO ACTUAL (MÁS RECIENTE)
  // ============================================
  Future<Precio?> getPrecioActual(int productoId, int mercadoId) async {
    try {
      final response = await supabase
          .from('precios')
          .select('*')
          .eq('producto_id', productoId)
          .eq('mercado_id', mercadoId)
          .order('fecha_actualizacion', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return Precio.fromMap(response);
    } catch (e) {
      print('Error al obtener precio actual: $e');
      return null;
    }
  }

  // ============================================
  // COMPARAR PRECIOS ENTRE MERCADOS
  // ============================================
  Future<Map<int, Precio>> compararPrecios(int productoId) async {
    try {
      // Usar la vista precios_actuales para obtener precios más recientes
      final response = await supabase
          .from('precios_actuales')
          .select('*')
          .eq('producto_id', productoId);

      final Map<int, Precio> preciosPorMercado = {};

      for (var json in response as List) {
        final precio = Precio.fromMap(json);
        preciosPorMercado[precio.mercadoId] = precio;
      }

      return preciosPorMercado;
    } catch (e) {
      throw Exception('Error al comparar precios: $e');
    }
  }

  // ============================================
  // REPORTAR NUEVO PRECIO
  // ============================================
  Future<void> reportarPrecio({
    required int productoId,
    required int mercadoId,
    required double precio,
    String? notas,
  }) async {
    final user = _authService.getCurrentUser();
    if (user == null) throw Exception('Usuario no autenticado');

    try {
      await supabase.from('precios').insert({
        'producto_id': productoId,
        'mercado_id': mercadoId,
        'precio': precio,
        'usuario_reporto_id': user.id,
        'notas': notas,
        'verificado': false,
      });
    } catch (e) {
      throw Exception('Error al reportar precio: $e');
    }
  }

  // ============================================
  // OBTENER PRECIO PROMEDIO (ÚLTIMOS 7 DÍAS)
  // ============================================
  Future<double> getPrecioPromedio(int productoId) async {
    try {
      // Usar la función SQL que creamos
      final response = await supabase.rpc(
        'obtener_precio_promedio',
        params: {'producto_id_param': productoId},
      );

      return (response as num).toDouble();
    } catch (e) {
      print('Error al obtener precio promedio: $e');
      return 0.0;
    }
  }

  // ============================================
  // MÉTODOS DE COMPATIBILIDAD
  // ============================================
  static Future<List<Precio>> fetchPricesByProduct(int productoId) async {
    final service = PrecioService();
    return await service.getPreciosProducto(productoId);
  }

  static Future<List<Precio>> fetchPricesByProductAndMarket(
    int productoId,
    int mercadoId,
  ) async {
    final service = PrecioService();
    return await service.getPreciosPorProductoYMercado(productoId, mercadoId);
  }

  static void addPrice(Precio precio) {
    // Ya no usamos esto, ahora se reporta a través de reportarPrecio
    // Mantener por compatibilidad pero no hace nada
  }
}
