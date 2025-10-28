import 'dart:math';

import 'package:monitoreo_precios/models/precio_model.dart';
import 'package:monitoreo_precios/services/precio_service.dart';

class HistorialService {
  // Genera historial sintético a partir de los precios actuales (promedio) para `days` días
  static Future<List<Precio>> generateHistory(int productoId, {int days = 7}) async {
    final current = await PrecioService.fetchPricesByProduct(productoId);
    double base = 5.0;
    if (current.isNotEmpty) {
      base = current.map((p) => p.valor).reduce((a, b) => a + b) / current.length;
    }
    final rng = Random(productoId + DateTime.now().millisecondsSinceEpoch % 1000);
    final List<Precio> history = [];
    for (int i = 0; i < days; i++) {
      final date = DateTime.now().subtract(Duration(days: days - 1 - i));
      final noise = (rng.nextDouble() - 0.5) * base * 0.06; // ±3%
      final value = (base + noise).clamp(0.1, double.infinity);
      history.add(Precio(id: 3000 + i, productoId: productoId, mercadoId: 0, valor: double.parse(value.toStringAsFixed(2)), fechaActualizacion: date));
    }
    return history;
  }
}

