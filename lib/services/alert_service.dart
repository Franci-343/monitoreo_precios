import 'dart:async';
import 'package:monitoreo_precios/main.dart';
import 'package:monitoreo_precios/models/precio_model.dart';
import 'package:monitoreo_precios/models/alerta_model.dart';

enum AlertDirection { above, below }

class PriceAlert {
  final int id;
  final int productoId;
  final double threshold;
  final AlertDirection direction;
  bool active;

  PriceAlert({
    required this.id,
    required this.productoId,
    required this.threshold,
    required this.direction,
    this.active = true,
  });
}

class AlertService {
  static final List<PriceAlert> _alerts = [];
  static int _nextId = 1;

  // ============================================
  // MÉTODOS LEGACY (Mantener compatibilidad)
  // ============================================

  static Future<PriceAlert> addAlert(
    int productoId,
    double threshold,
    AlertDirection direction,
  ) async {
    final alert = PriceAlert(
      id: _nextId++,
      productoId: productoId,
      threshold: threshold,
      direction: direction,
    );
    _alerts.add(alert);
    return alert;
  }

  static Future<List<PriceAlert>> getAlertsForProduct(int productoId) async {
    return _alerts.where((a) => a.productoId == productoId).toList();
  }

  static Future<void> removeAlert(int id) async {
    _alerts.removeWhere((a) => a.id == id);
  }

  // Devuelve la lista de alertas que se disparan dado un conjunto de precios
  static Future<List<PriceAlert>> checkAlertsForProduct(
    int productoId,
    List<Precio> precios,
  ) async {
    final relevant = _alerts
        .where((a) => a.productoId == productoId && a.active)
        .toList();
    final triggered = <PriceAlert>[];
    for (final a in relevant) {
      for (final p in precios) {
        if (a.direction == AlertDirection.above && p.valor > a.threshold) {
          triggered.add(a);
          break;
        }
        if (a.direction == AlertDirection.below && p.valor < a.threshold) {
          triggered.add(a);
          break;
        }
      }
    }
    return triggered;
  }

  // ============================================
  // NUEVOS MÉTODOS CON SUPABASE
  // ============================================

  /// Obtener todas las alertas de un usuario
  static Future<List<Alerta>> getAlertasUsuario(String usuarioId) async {
    try {
      final response = await supabase
          .from('alertas')
          .select('''
            *,
            productos!inner(nombre),
            mercados(nombre)
          ''')
          .eq('usuario_id', usuarioId)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        final alerta = Alerta.fromMap(json);
        // Agregar nombres de producto y mercado
        return Alerta(
          id: alerta.id,
          usuarioId: alerta.usuarioId,
          productoId: alerta.productoId,
          mercadoId: alerta.mercadoId,
          precioObjetivo: alerta.precioObjetivo,
          tipoAlerta: alerta.tipoAlerta,
          activo: alerta.activo,
          notificado: alerta.notificado,
          createdAt: alerta.createdAt,
          updatedAt: alerta.updatedAt,
          productoNombre: json['productos']?['nombre'],
          mercadoNombre: json['mercados']?['nombre'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener alertas: $e');
    }
  }

  /// Crear una nueva alerta
  static Future<Alerta> crearAlerta({
    required String usuarioId,
    required int productoId,
    int? mercadoId,
    required double precioObjetivo,
    required String tipoAlerta, // 'menor_o_igual' o 'mayor_o_igual'
  }) async {
    try {
      final response = await supabase
          .from('alertas')
          .insert({
            'usuario_id': usuarioId,
            'producto_id': productoId,
            if (mercadoId != null) 'mercado_id': mercadoId,
            'precio_objetivo': precioObjetivo,
            'tipo_alerta': tipoAlerta,
            'activo': true,
            'notificado': false,
          })
          .select()
          .single();

      return Alerta.fromMap(response);
    } catch (e) {
      throw Exception('Error al crear alerta: $e');
    }
  }

  /// Actualizar estado de una alerta (activar/desactivar)
  static Future<void> toggleAlerta(int alertaId, bool activo) async {
    try {
      await supabase
          .from('alertas')
          .update({
            'activo': activo,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', alertaId);
    } catch (e) {
      throw Exception('Error al actualizar alerta: $e');
    }
  }

  /// Eliminar una alerta
  static Future<void> eliminarAlerta(int alertaId) async {
    try {
      await supabase.from('alertas').delete().eq('id', alertaId);
    } catch (e) {
      throw Exception('Error al eliminar alerta: $e');
    }
  }

  /// Marcar alerta como notificada
  static Future<void> marcarComoNotificada(int alertaId) async {
    try {
      await supabase
          .from('alertas')
          .update({
            'notificado': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', alertaId);
    } catch (e) {
      throw Exception('Error al marcar alerta: $e');
    }
  }

  /// Obtener alertas activas no notificadas
  static Future<List<Alerta>> getAlertasActivasNoNotificadas(
    String usuarioId,
  ) async {
    try {
      final response = await supabase
          .from('alertas')
          .select('''
            *,
            productos!inner(nombre),
            mercados(nombre)
          ''')
          .eq('usuario_id', usuarioId)
          .eq('activo', true)
          .eq('notificado', false)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        final alerta = Alerta.fromMap(json);
        return Alerta(
          id: alerta.id,
          usuarioId: alerta.usuarioId,
          productoId: alerta.productoId,
          mercadoId: alerta.mercadoId,
          precioObjetivo: alerta.precioObjetivo,
          tipoAlerta: alerta.tipoAlerta,
          activo: alerta.activo,
          notificado: alerta.notificado,
          createdAt: alerta.createdAt,
          updatedAt: alerta.updatedAt,
          productoNombre: json['productos']?['nombre'],
          mercadoNombre: json['mercados']?['nombre'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener alertas activas: $e');
    }
  }
}
