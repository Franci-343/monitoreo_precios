import '../models/favorito_model.dart';
import '../services/auth_service.dart';
import '../main.dart';

class FavoritoService {
  // Singleton pattern
  static final FavoritoService _instance = FavoritoService._internal();
  factory FavoritoService() => _instance;
  FavoritoService._internal();

  final _authService = AuthService();

  // ============================================
  // OBTENER FAVORITOS DEL USUARIO ACTUAL
  // ============================================
  Future<List<Favorito>> getFavoritos() async {
    final user = _authService.getCurrentUser();
    if (user == null) throw Exception('Usuario no autenticado');

    try {
      final response = await supabase
          .from('favoritos')
          .select('*')
          .eq('usuario_id', user.id)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Favorito.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener favoritos: $e');
    }
  }

  // ============================================
  // AGREGAR A FAVORITOS
  // ============================================
  Future<void> agregarFavorito(int productoId) async {
    final user = _authService.getCurrentUser();
    if (user == null) throw Exception('Usuario no autenticado');

    try {
      await supabase.from('favoritos').insert({
        'usuario_id': user.id,
        'producto_id': productoId,
      });
    } catch (e) {
      throw Exception('Error al agregar favorito: $e');
    }
  }

  // ============================================
  // ELIMINAR DE FAVORITOS
  // ============================================
  Future<void> eliminarFavorito(int favoritoId) async {
    try {
      await supabase.from('favoritos').delete().eq('id', favoritoId);
    } catch (e) {
      throw Exception('Error al eliminar favorito: $e');
    }
  }

  // ============================================
  // ELIMINAR POR PRODUCTO ID
  // ============================================
  Future<void> eliminarFavoritoPorProducto(int productoId) async {
    final user = _authService.getCurrentUser();
    if (user == null) throw Exception('Usuario no autenticado');

    try {
      await supabase
          .from('favoritos')
          .delete()
          .eq('usuario_id', user.id)
          .eq('producto_id', productoId);
    } catch (e) {
      throw Exception('Error al eliminar favorito: $e');
    }
  }

  // ============================================
  // VERIFICAR SI UN PRODUCTO ES FAVORITO
  // ============================================
  Future<bool> esFavorito(int productoId) async {
    final user = _authService.getCurrentUser();
    if (user == null) return false;

    try {
      final response = await supabase
          .from('favoritos')
          .select()
          .eq('usuario_id', user.id)
          .eq('producto_id', productoId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // TOGGLE FAVORITO
  // ============================================
  Future<void> toggleFavorito(int productoId) async {
    final isFav = await esFavorito(productoId);

    if (isFav) {
      await eliminarFavoritoPorProducto(productoId);
    } else {
      await agregarFavorito(productoId);
    }
  }

  // ============================================
  // MÉTODOS DE COMPATIBILIDAD (para código anterior)
  // ============================================
  static Future<List<Favorito>> getFavoritesForUser(int usuarioId) async {
    // Para compatibilidad, pero ahora usamos el usuario autenticado
    final service = FavoritoService();
    return await service.getFavoritos();
  }

  static Future<bool> isFavorite(int usuarioId, int productoId) async {
    final service = FavoritoService();
    return await service.esFavorito(productoId);
  }

  static Future<void> addFavorite(int usuarioId, int productoId) async {
    final service = FavoritoService();
    await service.agregarFavorito(productoId);
  }

  static Future<void> removeFavorite(int usuarioId, int productoId) async {
    final service = FavoritoService();
    await service.eliminarFavoritoPorProducto(productoId);
  }

  static Future<void> toggleFavorite(int usuarioId, int productoId) async {
    final service = FavoritoService();
    await service.toggleFavorito(productoId);
  }
}
