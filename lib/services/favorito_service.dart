import 'dart:async';

import 'package:monitoreo_precios/models/favorito_model.dart';

/// Servicio de favoritos en memoria (simula persistencia).
///
/// Nota: esto evita la dependencia en `shared_preferences` y mantiene
/// la misma API que antes. Más adelante se puede reemplazar por
/// SharedPreferences o Hive sin cambiar el resto de la app.
class FavoritoService {
  // Mapa usuarioId -> Set<productoId>
  static final Map<int, Set<int>> _memoryFavorites = {};

  static Future<void> _ensureUser(int usuarioId) async {
    _memoryFavorites.putIfAbsent(usuarioId, () => <int>{});
  }

  static Future<List<Favorito>> getFavoritesForUser(int usuarioId) async {
    await _ensureUser(usuarioId);
    final set = _memoryFavorites[usuarioId]!;
    return set.map((pid) => Favorito(id: pid, usuarioId: usuarioId, productoId: pid)).toList();
  }

  static Future<bool> isFavorite(int usuarioId, int productoId) async {
    await _ensureUser(usuarioId);
    return _memoryFavorites[usuarioId]!.contains(productoId);
  }

  static Future<void> addFavorite(int usuarioId, int productoId) async {
    await _ensureUser(usuarioId);
    _memoryFavorites[usuarioId]!.add(productoId);
    // Simular latencia
    await Future.delayed(const Duration(milliseconds: 50));
  }

  static Future<void> removeFavorite(int usuarioId, int productoId) async {
    await _ensureUser(usuarioId);
    _memoryFavorites[usuarioId]!.remove(productoId);
    await Future.delayed(const Duration(milliseconds: 50));
  }

  static Future<void> toggleFavorite(int usuarioId, int productoId) async {
    final exists = await isFavorite(usuarioId, productoId);
    if (exists) {
      await removeFavorite(usuarioId, productoId);
    } else {
      await addFavorite(usuarioId, productoId);
    }
  }
}
