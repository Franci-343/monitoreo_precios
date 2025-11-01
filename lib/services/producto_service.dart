import '../models/producto_model.dart';
import '../models/mercado_model.dart';
import '../models/categoria_model.dart';
import '../main.dart';

class ProductoService {
  // Singleton pattern
  static final ProductoService _instance = ProductoService._internal();
  factory ProductoService() => _instance;
  ProductoService._internal();

  // ============================================
  // OBTENER TODOS LOS PRODUCTOS
  // ============================================
  Future<List<Producto>> getProductos() async {
    try {
      final response = await supabase
          .from('productos')
          .select('id, nombre, categoria_id, unidad_medida, categorias(nombre)')
          .eq('activo', true)
          .order('nombre');

      return (response as List).map((json) {
        return Producto(
          id: json['id'] as int,
          nombre: json['nombre'] as String,
          categoria: json['categorias']['nombre'] as String,
          categoriaId: json['categoria_id'] as int,
          unidadMedida: json['unidad_medida'] as String?,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener productos: $e');
    }
  }

  // ============================================
  // BUSCAR PRODUCTOS POR NOMBRE
  // ============================================
  Future<List<Producto>> buscarProductos(String query) async {
    try {
      final response = await supabase
          .from('productos')
          .select('id, nombre, categoria_id, unidad_medida, categorias(nombre)')
          .ilike('nombre', '%$query%')
          .eq('activo', true)
          .order('nombre');

      return (response as List).map((json) {
        return Producto(
          id: json['id'] as int,
          nombre: json['nombre'] as String,
          categoria: json['categorias']['nombre'] as String,
          categoriaId: json['categoria_id'] as int,
          unidadMedida: json['unidad_medida'] as String?,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al buscar productos: $e');
    }
  }

  // ============================================
  // OBTENER PRODUCTOS POR CATEGORÍA
  // ============================================
  Future<List<Producto>> getProductosPorCategoria(String categoria) async {
    try {
      // Primero obtenemos el ID de la categoría
      final catResponse = await supabase
          .from('categorias')
          .select('id')
          .eq('nombre', categoria)
          .single();

      final categoriaId = catResponse['id'] as int;

      final response = await supabase
          .from('productos')
          .select('id, nombre, categoria_id, unidad_medida, categorias(nombre)')
          .eq('categoria_id', categoriaId)
          .eq('activo', true)
          .order('nombre');

      return (response as List).map((json) {
        return Producto(
          id: json['id'] as int,
          nombre: json['nombre'] as String,
          categoria: json['categorias']['nombre'] as String,
          categoriaId: json['categoria_id'] as int,
          unidadMedida: json['unidad_medida'] as String?,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener productos por categoría: $e');
    }
  }

  // ============================================
  // OBTENER UN PRODUCTO POR ID
  // ============================================
  Future<Producto?> getProductoPorId(int id) async {
    try {
      final response = await supabase
          .from('productos')
          .select('id, nombre, categoria_id, unidad_medida, categorias(nombre)')
          .eq('id', id)
          .single();

      return Producto(
        id: response['id'] as int,
        nombre: response['nombre'] as String,
        categoria: response['categorias']['nombre'] as String,
        categoriaId: response['categoria_id'] as int,
        unidadMedida: response['unidad_medida'] as String?,
      );
    } catch (e) {
      print('Error al obtener producto: $e');
      return null;
    }
  }

  // ============================================
  // OBTENER CATEGORÍAS
  // ============================================
  Future<List<String>> getCategoriasNombres() async {
    try {
      final response = await supabase
          .from('categorias')
          .select('nombre')
          .eq('activo', true)
          .order('orden');

      return (response as List)
          .map((json) => json['nombre'] as String)
          .toList();
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  // ============================================
  // OBTENER CATEGORÍAS COMPLETAS
  // ============================================
  Future<List<Categoria>> getCategorias() async {
    try {
      final response = await supabase
          .from('categorias')
          .select('*')
          .eq('activo', true)
          .order('orden');

      return (response as List).map((json) => Categoria.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  // ============================================
  // OBTENER PRODUCTOS POR ID DE CATEGORÍA
  // ============================================
  Future<List<Producto>> getProductosPorCategoriaId(int categoriaId) async {
    try {
      final response = await supabase
          .from('productos')
          .select('id, nombre, categoria_id, unidad_medida, categorias(nombre)')
          .eq('categoria_id', categoriaId)
          .eq('activo', true)
          .order('nombre');

      return (response as List).map((json) {
        return Producto(
          id: json['id'] as int,
          nombre: json['nombre'] as String,
          categoria: json['categorias']['nombre'] as String,
          categoriaId: json['categoria_id'] as int,
          unidadMedida: json['unidad_medida'] as String?,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener productos por categoría: $e');
    }
  }

  // ============================================
  // OBTENER MERCADOS
  // ============================================
  Future<List<Mercado>> getMercados() async {
    try {
      final response = await supabase
          .from('mercados')
          .select('*')
          .eq('activo', true)
          .order('nombre');

      return (response as List).map((json) => Mercado.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener mercados: $e');
    }
  }

  // ============================================
  // MÉTODOS DE COMPATIBILIDAD CON CÓDIGO ANTERIOR
  // ============================================
  static Future<List<Producto>> fetchProducts({
    String? query,
    String? categoria,
  }) async {
    final service = ProductoService();

    if (categoria != null && categoria.isNotEmpty) {
      return await service.getProductosPorCategoria(categoria);
    } else if (query != null && query.trim().isNotEmpty) {
      return await service.buscarProductos(query);
    } else {
      return await service.getProductos();
    }
  }

  static Future<List<String>> fetchCategories() async {
    final service = ProductoService();
    return await service.getCategoriasNombres();
  }

  static Future<List<Categoria>> fetchCategoriesComplete() async {
    final service = ProductoService();
    return await service.getCategorias();
  }

  static Future<List<Producto>> fetchProductsByCategory(int categoriaId) async {
    final service = ProductoService();
    return await service.getProductosPorCategoriaId(categoriaId);
  }

  static Future<List<Mercado>> fetchMarkets() async {
    final service = ProductoService();
    return await service.getMercados();
  }

  static Future<List<Mercado>> getMarketsSync() async {
    final service = ProductoService();
    return await service.getMercados();
  }
}
