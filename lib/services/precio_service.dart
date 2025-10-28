import 'dart:async';

import 'package:monitoreo_precios/models/precio_model.dart';

class PrecioService {
  static final List<Precio> _precios = [
    // Producto 1: Papa
    Precio(id: 1, productoId: 1, mercadoId: 1, valor: 3.50, fechaActualizacion: DateTime.now().subtract(const Duration(days: 1))),
    Precio(id: 2, productoId: 1, mercadoId: 2, valor: 3.20, fechaActualizacion: DateTime.now().subtract(const Duration(days: 2))),
    Precio(id: 3, productoId: 1, mercadoId: 3, valor: 3.75, fechaActualizacion: DateTime.now().subtract(const Duration(days: 1))),
    // Producto 2: Tomate
    Precio(id: 4, productoId: 2, mercadoId: 1, valor: 4.10, fechaActualizacion: DateTime.now().subtract(const Duration(days: 3))),
    Precio(id: 5, productoId: 2, mercadoId: 2, valor: 3.95, fechaActualizacion: DateTime.now().subtract(const Duration(days: 1))),
    // Producto 3: Pollo
    Precio(id: 6, productoId: 3, mercadoId: 1, valor: 18.50, fechaActualizacion: DateTime.now().subtract(const Duration(days: 2))),
    Precio(id: 7, productoId: 3, mercadoId: 3, valor: 17.75, fechaActualizacion: DateTime.now().subtract(const Duration(days: 1))),
    // Producto 4: Manzana
    Precio(id: 8, productoId: 4, mercadoId: 2, valor: 6.20, fechaActualizacion: DateTime.now().subtract(const Duration(days: 4))),
    Precio(id: 9, productoId: 4, mercadoId: 4, valor: 5.95, fechaActualizacion: DateTime.now().subtract(const Duration(days: 1))),
    // Producto 5: Plátano
    Precio(id: 10, productoId: 5, mercadoId: 1, valor: 2.80, fechaActualizacion: DateTime.now().subtract(const Duration(days: 1))),
    Precio(id: 11, productoId: 5, mercadoId: 2, valor: 2.65, fechaActualizacion: DateTime.now().subtract(const Duration(days: 2))),
    // Producto 6: Lechuga
    Precio(id: 12, productoId: 6, mercadoId: 3, valor: 1.50, fechaActualizacion: DateTime.now().subtract(const Duration(days: 1))),
  ];

  static Future<List<Precio>> fetchPricesByProduct(int productoId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _precios.where((p) => p.productoId == productoId).toList();
  }

  static Future<List<Precio>> fetchPricesByProductAndMarket(int productoId, int mercadoId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _precios.where((p) => p.productoId == productoId && p.mercadoId == mercadoId).toList();
  }

  // Para futuro: agregar reportes locales
  static void addPrice(Precio precio) {
    _precios.add(precio);
  }
}
