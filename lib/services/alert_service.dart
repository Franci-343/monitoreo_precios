import 'dart:async';

import 'package:monitoreo_precios/models/precio_model.dart';

enum AlertDirection { above, below }

class PriceAlert {
  final int id;
  final int productoId;
  final double threshold;
  final AlertDirection direction;
  bool active;

  PriceAlert({required this.id, required this.productoId, required this.threshold, required this.direction, this.active = true});
}

class AlertService {
  static final List<PriceAlert> _alerts = [];
  static int _nextId = 1;

  static Future<PriceAlert> addAlert(int productoId, double threshold, AlertDirection direction) async {
    final alert = PriceAlert(id: _nextId++, productoId: productoId, threshold: threshold, direction: direction);
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
  static Future<List<PriceAlert>> checkAlertsForProduct(int productoId, List<Precio> precios) async {
    final relevant = _alerts.where((a) => a.productoId == productoId && a.active).toList();
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
}

