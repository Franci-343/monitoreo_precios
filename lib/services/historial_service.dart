import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monitoreo_precios/models/precio_model.dart';
import 'package:monitoreo_precios/models/producto_model.dart';
import 'package:monitoreo_precios/services/precio_service.dart';
import 'package:monitoreo_precios/services/producto_service.dart';

class HistorialService {
  static const String _historialKey = 'historial_consultas';
  static const int _maxHistorial = 50; // Máximo de productos en historial

  // Genera historial sintético a partir de los precios actuales (promedio) para `days` días
  static Future<List<Precio>> generateHistory(
    int productoId, {
    int days = 7,
  }) async {
    final current = await PrecioService.fetchPricesByProduct(productoId);
    double base = 5.0;
    if (current.isNotEmpty) {
      base =
          current.map((p) => p.valor).reduce((a, b) => a + b) / current.length;
    }
    final rng = Random(
      productoId + DateTime.now().millisecondsSinceEpoch % 1000,
    );
    final List<Precio> history = [];
    for (int i = 0; i < days; i++) {
      final date = DateTime.now().subtract(Duration(days: days - 1 - i));
      final noise = (rng.nextDouble() - 0.5) * base * 0.06; // ±3%
      final value = (base + noise).clamp(0.1, double.infinity);
      history.add(
        Precio(
          id: 3000 + i,
          productoId: productoId,
          mercadoId: 0,
          valor: double.parse(value.toStringAsFixed(2)),
          fechaActualizacion: date,
        ),
      );
    }
    return history;
  }

  // ============================================
  // NUEVO: Gestión de Historial de Consultas
  // ============================================

  /// Agregar un producto al historial de consultas
  static Future<void> agregarAlHistorial(int productoId) async {
    final prefs = await SharedPreferences.getInstance();
    final historialJson = prefs.getString(_historialKey);

    List<Map<String, dynamic>> historial = [];
    if (historialJson != null) {
      historial = List<Map<String, dynamic>>.from(jsonDecode(historialJson));
    }

    // Eliminar el producto si ya existe (para actualizarlo al principio)
    historial.removeWhere((item) => item['producto_id'] == productoId);

    // Agregar al principio
    historial.insert(0, {
      'producto_id': productoId,
      'fecha': DateTime.now().toIso8601String(),
    });

    // Limitar el tamaño del historial
    if (historial.length > _maxHistorial) {
      historial = historial.sublist(0, _maxHistorial);
    }

    // Guardar
    await prefs.setString(_historialKey, jsonEncode(historial));
  }

  /// Obtener el historial de consultas con información de productos
  static Future<List<Map<String, dynamic>>> getHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final historialJson = prefs.getString(_historialKey);

    if (historialJson == null) return [];

    final historialData = List<Map<String, dynamic>>.from(
      jsonDecode(historialJson),
    );

    // Cargar todos los productos
    final todosProductos = await ProductoService.fetchProducts();

    // Mapear IDs de productos a objetos Producto completos
    final List<Map<String, dynamic>> historialCompleto = [];

    for (final item in historialData) {
      final productoId = item['producto_id'] as int;
      final fecha = DateTime.parse(item['fecha'] as String);

      // Buscar el producto
      final producto = todosProductos.firstWhere(
        (p) => p.id == productoId,
        orElse: () => Producto(
          id: productoId,
          nombre: 'Producto no encontrado',
          categoria: 'Sin categoría',
        ),
      );

      historialCompleto.add({'producto': producto, 'fecha': fecha});
    }

    return historialCompleto;
  }

  /// Eliminar un producto específico del historial
  static Future<void> eliminarDelHistorial(int productoId) async {
    final prefs = await SharedPreferences.getInstance();
    final historialJson = prefs.getString(_historialKey);

    if (historialJson == null) return;

    List<Map<String, dynamic>> historial = List<Map<String, dynamic>>.from(
      jsonDecode(historialJson),
    );

    // Eliminar el producto
    historial.removeWhere((item) => item['producto_id'] == productoId);

    // Guardar
    await prefs.setString(_historialKey, jsonEncode(historial));
  }

  /// Limpiar todo el historial
  static Future<void> limpiarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historialKey);
  }

  /// Obtener la cantidad de productos en el historial
  static Future<int> getCantidadHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final historialJson = prefs.getString(_historialKey);

    if (historialJson == null) return 0;

    final historial = List<Map<String, dynamic>>.from(
      jsonDecode(historialJson),
    );
    return historial.length;
  }
}
