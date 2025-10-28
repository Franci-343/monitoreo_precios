import 'dart:async';

import 'package:monitoreo_precios/models/producto_model.dart';
import 'package:monitoreo_precios/models/mercado_model.dart';

class ProductoService {
  // Datos simulados en memoria
  static final List<Producto> _productos = [
    Producto(id: 1, nombre: 'Papa', categoria: 'Verduras'),
    Producto(id: 2, nombre: 'Tomate', categoria: 'Verduras'),
    Producto(id: 3, nombre: 'Pollo', categoria: 'Carnes'),
    Producto(id: 4, nombre: 'Manzana', categoria: 'Frutas'),
    Producto(id: 5, nombre: 'Plátano', categoria: 'Frutas'),
    Producto(id: 6, nombre: 'Lechuga', categoria: 'Verduras'),
  ];

  static final List<Mercado> _mercados = [
    Mercado(id: 1, nombre: 'Mercado Rodríguez', zona: 'Centro'),
    Mercado(id: 2, nombre: 'Feria Achumani', zona: 'Achumani'),
    Mercado(id: 3, nombre: 'Mercado 16 de Julio', zona: 'Obrajes'),
    Mercado(id: 4, nombre: 'Feria San Miguel', zona: 'San Miguel'),
  ];

  // Simula una petición async
  static Future<List<Producto>> fetchProducts({String? query, String? categoria}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    Iterable<Producto> items = _productos;
    if (categoria != null && categoria.isNotEmpty) {
      items = items.where((p) => p.categoria.toLowerCase() == categoria.toLowerCase());
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      items = items.where((p) => p.nombre.toLowerCase().contains(q));
    }
    return items.toList();
  }

  static Future<List<String>> fetchCategories() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final cats = _productos.map((p) => p.categoria).toSet().toList();
    cats.sort();
    return cats;
  }

  static Future<List<Mercado>> fetchMarkets() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<Mercado>.from(_mercados);
  }

  // Sync access for small prototipos
  static List<Mercado> getMarketsSync() => _mercados;
}
